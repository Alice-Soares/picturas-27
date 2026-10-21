'use strict';

// UC-VID-006: Worker de concatenação para a fila video_merge.
// As dependências reais são carregadas apenas quando executadas, permitindo
// testes unitários sem Docker, MongoDB, RabbitMQ, FFmpeg e node_modules.

function errorCode(error) {
  if (error?.message === 'VIDEO_MERGE_CANCELLED' || error?.name === 'AbortError') {
    return 'VIDEO_MERGE_CANCELLED';
  }
  const allowed = new Set([
    'VIDEO_MERGE_NOT_FOUND', 'VIDEO_MERGE_SOURCE_REMOVED',
    'VIDEO_MERGE_INVALID_SOURCE', 'VIDEO_MERGE_PROJECT_CONFLICT',
  ]);
  return allowed.has(error?.message) ? error.message : 'VIDEO_MERGE_FAILED';
}

function defaults() {
  const model = () => require('../models/videoOperation');
  return {
    claim: (operationId) => model().findOneAndUpdate(
      { _id: operationId, type: 'merge', status: 'queued' },
      { $set: { status: 'processing', started_at: new Date(), progress: 1 } },
      { new: true },
    ).exec(),
    status: async (operationId) => {
      const operation = await model().findById(operationId).select('status').lean().exec();
      return operation?.status ?? null;
    },
    project: (operation) => require('../controllers/project').getOne(
      operation.user_id, operation.project_id,
    ),
    progress: (operationId, value) => model().findOneAndUpdate(
      { _id: operationId, type: 'merge', status: 'processing' },
      { $set: { progress: Math.min(95, Math.max(1, Math.round(value))) } },
      { new: true },
    ).exec(),
    complete: (operationId, videoId) => model().findOneAndUpdate(
      { _id: operationId, type: 'merge', status: 'processing' },
      { $set: { status: 'completed', progress: 100, result_video_id: videoId, finished_at: new Date() } },
      { new: true },
    ).exec(),
    fail: async (operationId, error) => {
      const updated = await model().findOneAndUpdate(
        { _id: operationId, type: 'merge', status: 'processing' },
        { $set: { status: 'failed', error_code: errorCode(error), finished_at: new Date() } },
        { new: true },
      ).exec();
      if (!updated) return null;
      // Compensação da quota em falha, seguindo o contrato do serviço Users.
      // A idempotência entre falhas de rede e reembolsos simultâneos continua
      // a exigir um mecanismo transacional ou uma chave idempotente.
      if (updated.quota_reserved && !updated.quota_refunded) {
        const axios = require('axios');
        const https = require('https');
        await axios.post(
          `https://users:10001/${updated.user_id}/process/refund/1`, null,
          { httpsAgent: new https.Agent({ rejectUnauthorized: false }) },
        );
        await model().updateOne(
          { _id: operationId, type: 'merge', status: 'failed' },
          { $set: { quota_refunded: true } },
        ).exec();
      }
      return updated;
    },
    // Compensação se o resultado for guardado e a operação for cancelada antes
    // da transição atómica para completed. Não elimina os vídeos de origem.
    undoSaved: async (operation, result) => {
      const videoId = result?.savedResult?.videoId;
      const objectKey = result?.objectKey;
      if (!videoId || !objectKey) return;
      const ProjectModel = require('../models/project');
      const update = await ProjectModel.updateOne(
        { _id: operation.project_id, user_id: operation.user_id, 'videos._id': videoId },
        { $pull: { videos: { _id: videoId } }, $inc: { version: 1 } },
      ).exec();
      // Se o resultado já não existir na BD, a limpeza remota pode continuar.
      if (update.acknowledged === false) throw new Error('VIDEO_MERGE_ROLLBACK_FAILED');
      await require('../utils/videoStorage').delete_video(
        operation.user_id, operation.project_id, objectKey,
      );
    },
    publish: (operation) => require('../utils/project_msg').send_msg_project_op({
      projectId: String(operation.project_id),
      ownerId: String(operation.user_id),
      op: require('../utils/videoOperationMsg').operationEvent(operation),
    }),
    pipeline: async (args) => {
      const { createVideoMergeStorageAdapter, createVideoMergeSaveResult } = require('./videoMergeAdapters');
      const { runVideoMergePipeline } = require('./videoMergePipeline');
      return runVideoMergePipeline({
        ...args,
        storage: createVideoMergeStorageAdapter(),
        saveResult: createVideoMergeSaveResult({ checkCancelled: args.checkCancelled }),
      });
    },
  };
}

function selectSources(operation, project) {
  if (!project?.videos || !Array.isArray(operation?.source_video_ids) || operation.source_video_ids.length < 2) {
    throw new Error('VIDEO_MERGE_NOT_FOUND');
  }
  // Reconstituir os vídeos na ordem guardada na operação; nunca na ordem da BD.
  return operation.source_video_ids.map((id) => {
    const found = Array.from(project.videos).find((video) => String(video._id) === String(id));
    if (!found || !found.object_key) throw new Error('VIDEO_MERGE_SOURCE_REMOVED');
    return found;
  });
}

function createVideoMergeWorker(injected = {}, { pollMs = 500 } = {}) {
  const deps = { ...defaults(), ...injected };
  async function safePublish(operation) {
    try { if (operation) await deps.publish(operation); }
    catch (e) { console.error('UC-VID-006: notificação falhou:', e.message); }
  }

  async function runMergeOperation(operationId) {
    if (!operationId) throw new Error('VIDEO_MERGE_OPERATION_REQUIRED');
    const operation = await deps.claim(operationId);
    // Sem claim não devemos executar a mesma mensagem duas vezes nem reabrir
    // operações terminais/canceladas.
    if (!operation) return { skipped: true };
    await safePublish(operation);

    const controller = new AbortController();
    const checkCancelled = async () => {
      const status = await deps.status(operationId);
      if (status === 'cancelled') controller.abort();
      if (controller.signal.aborted) throw new Error('VIDEO_MERGE_CANCELLED');
      if (status !== 'processing') throw new Error('VIDEO_MERGE_OPERATION_NOT_PROCESSING');
    };
    const timer = setInterval(() => {
      checkCancelled().catch((error) => {
        // Não converter problemas transitórios de BD em cancelamento.
        if (error.message !== 'VIDEO_MERGE_CANCELLED') {
          console.error('UC-VID-006: consulta de estado falhou:', error.message);
        }
      });
    }, pollMs);

    let lastProgress = 1;
    let pipelineResult = null;
    try {
      const project = await deps.project(operation);
      const videos = selectSources(operation, project);
      await checkCancelled();
      pipelineResult = await deps.pipeline({
        userId: operation.user_id,
        projectId: operation.project_id,
        videos,
        signal: controller.signal,
        checkCancelled,
        onProgress: (value) => {
          if (!Number.isFinite(value)) return;
          const next = Math.min(95, Math.max(1, Math.round(value)));
          if (next < lastProgress + 5) return;
          lastProgress = next;
          Promise.resolve().then(() => deps.progress(operationId, next)).then(safePublish)
            .catch((e) => console.error('UC-VID-006: progresso falhou:', e.message));
        },
      });
      await checkCancelled();
      const videoId = pipelineResult?.savedResult?.videoId;
      if (!videoId) throw new Error('VIDEO_MERGE_RESULT_NOT_REGISTERED');
      const completed = await deps.complete(operationId, videoId);
      if (!completed) throw new Error('VIDEO_MERGE_CANCELLED');
      await safePublish(completed);
      return { completed: true, videoId };
    } catch (error) {
      const status = await deps.status(operationId).catch(() => null);
      if (pipelineResult && ['cancelled', 'processing', 'failed'].includes(status)) {
        try { await deps.undoSaved(operation, pipelineResult); }
        catch (rollbackError) {
          console.error('UC-VID-006: compensação de resultado pendente:', rollbackError.message);
        }
      }
      if (controller.signal.aborted || status === 'cancelled' || errorCode(error) === 'VIDEO_MERGE_CANCELLED') {
        return { cancelled: true };
      }
      try { await safePublish(await deps.fail(operationId, error)); }
      catch (failure) { console.error('UC-VID-006: não foi possível registar falha/reembolso:', failure.message); }
      return { failed: true, errorCode: errorCode(error) };
    } finally {
      clearInterval(timer);
    }
  }

  return { runMergeOperation };
}

function parseMergeQueueMessage(message) {
  try {
    const body = JSON.parse(message?.content?.toString('utf8') || '');
    return typeof body?.operationId === 'string' && body.operationId.trim()
      ? body.operationId
      : null;
  } catch { return null; }
}

function startMergeWorker(dependencies, { consumer = require('../utils/videoMergeQueue').consumeMergeQueue } = {}) {
  const worker = createVideoMergeWorker(dependencies);
  // O consumidor aguarda a Promise completa do worker antes do ACK.
  const ready = consumer(async (message) => {
    const operationId = parseMergeQueueMessage(message);
    if (!operationId || !/^[a-f0-9]{24}$/i.test(operationId)) {
      console.error('UC-VID-006: ID inválido na fila video_merge');
      return; // descartar mensagem malformada (ACK), sem retry infinito
    }
    return worker.runMergeOperation(operationId);
  });
  return { ...worker, ready };
}

module.exports = { createVideoMergeWorker, startMergeWorker, selectSources, parseMergeQueueMessage };
