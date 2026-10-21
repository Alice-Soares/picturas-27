'use strict';

// UC-VID-006: pipeline de processamento de múltiplas fontes.
// Adapta as funcionalidades já existentes; NÃO abre conexões Mongo/RabbitMQ.
// Os adaptadores (storage/saveResult) são injetados para permitir testes sem Docker.
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const { mergeLocalVideos } = require('./videoMergeProcessor');
// A função é carregada apenas quando o leitor por omissão é realmente usado.
// Nos testes, o leitor de metadados é injetado e não precisamos desse módulo.
async function defaultMetadataReader(file) {
  let readVideoMetadata;
  try {
    ({ readVideoMetadata } = require('./videoMetadata'));
  } catch (error) {
    if (error.code === 'MODULE_NOT_FOUND' && error.message.includes("'./videoMetadata'")) {
      throw new Error('VIDEO_MERGE_METADATA_READER_UNAVAILABLE');
    }
    throw error;
  }
  return readVideoMetadata(file);
}

function checkAbort(signal) {
  if (!signal?.aborted) return;
  const error = new Error('VIDEO_MERGE_CANCELLED');
  error.name = 'AbortError';
  throw error;
}

/**
 * Processa vídeos previamente validados e ordenados.
 * @param {object} args
 * @param {Array<{_id: unknown, object_key: string}>} args.videos
 *   Videos pertencentes ao projeto, pela ordem pedida (validar ANTES de invocar).
 * @param {object} args.storage
 *   downloadVideo({userId, projectId, objectKey, destination}) -> Promise<void>
 *   uploadVideo({userId, projectId, filePath, name}) -> Promise<{objectKey}>
 *   deleteVideo({userId, projectId, objectKey}) -> Promise<void>
 * @param {function} args.saveResult
 *   Deve persistir o novo vídeo no projeto e rejeitar conflito/cancelamento.
 * @param {function} [args.processor] Processador local injetável (default FFmpeg).
 * @param {function} [args.metadataReader] Lê metadados completos (default FFprobe).
 * @returns {Promise<{objectKey: string, metadata: object, savedResult: unknown}>}
 */
async function runVideoMergePipeline({
  userId,
  projectId,
  videos,
  storage,
  saveResult,
  processor = mergeLocalVideos,
  metadataReader = defaultMetadataReader,
  signal,
  onProgress,
  outputName = 'concatenado.mp4',
  tempRoot = os.tmpdir(),
}) {
  if (!Array.isArray(videos) || videos.length < 2 ||
      videos.some((video) => !video || typeof video.object_key !== 'string' || !video.object_key)) {
    throw new Error('VIDEO_MERGE_INVALID_SELECTION');
  }
  if (!storage || ['downloadVideo', 'uploadVideo', 'deleteVideo'].some((name) => typeof storage[name] !== 'function')) {
    throw new Error('VIDEO_MERGE_STORAGE_ADAPTER_REQUIRED');
  }
  if (typeof saveResult !== 'function') throw new Error('VIDEO_MERGE_SAVE_RESULT_REQUIRED');
  if (outputName !== 'concatenado.mp4') throw new Error('VIDEO_MERGE_OUTPUT_NAME_UNSUPPORTED');
  checkAbort(signal);

  const tempDir = await fs.mkdtemp(path.join(tempRoot, 'picturas-merge-'));
  const outputPath = path.join(tempDir, 'concatenado.mp4');
  let uploadedObjectKey = null;
  let saved = false;
  try {
    const inputPaths = [];
    for (let index = 0; index < videos.length; index++) {
      checkAbort(signal);
      const destination = path.join(tempDir, `input-${index}.mp4`);
      await storage.downloadVideo({
        userId,
        projectId,
        objectKey: videos[index].object_key,
        destination,
      });
      // A ordenação é definida pelo utilizador: não ordenar inputPaths.
      inputPaths.push(destination);
    }

    checkAbort(signal);
    await processor({ inputPaths, outputPath, signal, onProgress });
    checkAbort(signal);

    // Metadados completos exigidos pelo esquema project.videos (sha256, size, etc.).
    const metadata = await metadataReader({ path: outputPath, originalname: outputName });
    checkAbort(signal);
    const uploaded = await storage.uploadVideo({ userId, projectId, filePath: outputPath, name: outputName });
    uploadedObjectKey = uploaded?.objectKey;
    if (!uploadedObjectKey || typeof uploadedObjectKey !== 'string') {
      throw new Error('VIDEO_MERGE_UPLOAD_MISSING_KEY');
    }
    checkAbort(signal);
    const savedResult = await saveResult({
      userId,
      projectId,
      sourceVideoIds: videos.map((video) => String(video._id)),
      objectKey: uploadedObjectKey,
      name: outputName,
      metadata,
    });
    saved = true;
    onProgress?.(100);
    return { objectKey: uploadedObjectKey, metadata, savedResult };
  } catch (error) {
    // Se falhar a gravação no projeto, não deixar um ficheiro órfão no armazenamento.
    // A falha de limpeza não oculta o erro original.
    if (uploadedObjectKey && !saved) {
      try {
        await storage.deleteVideo({ userId, projectId, objectKey: uploadedObjectKey });
      } catch (cleanupError) {
        console.error('UC-VID-006: falha a eliminar objeto órfão:', cleanupError.message);
      }
    }
    throw error;
  } finally {
    await fs.rm(tempDir, { recursive: true, force: true });
  }
}

module.exports = { runVideoMergePipeline, checkAbort };
