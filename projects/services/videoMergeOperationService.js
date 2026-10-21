"use strict";

// UC-VID-006 — Ciclo de vida das operações MERGE.
// As dependências podem ser injetadas, permitindo testes sem Docker/npm/MongoDB.
const { validateMergeSelection } = require("./videoMergeValidation");

function mergeError(code, status = 400) {
  const error = new Error(code);
  error.status = status;
  return error;
}

function publicMergeError(error) {
  const known = new Set([
    "VIDEO_MERGE_UNAUTHORIZED", "VIDEO_MERGE_NOT_FOUND", "VIDEO_MERGE_TOO_FEW_VIDEOS",
    "VIDEO_MERGE_TOO_MANY_VIDEOS", "VIDEO_MERGE_DURATION_EXCEEDED",
    "VIDEO_MERGE_INVALID_VIDEO", "VIDEO_MERGE_INVALID_PROJECT_VIDEOS",
    "VIDEO_MERGE_QUOTA_EXCEEDED", "VIDEO_MERGE_CANCELLED",
  ]);
  return known.has(error?.message) ? error.message : "VIDEO_MERGE_FAILED";
}

function defaultDependencies() {
  const operationModel = () => require("../models/videoOperation");
  const usersUrl = "https://users:10001";
  const usersClient = async () => {
    const axios = require("axios");
    const https = require("https");
    return { axios, httpsAgent: new https.Agent({ rejectUnauthorized: false }) };
  };
  return {
    getProject: (userId, projectId) => require("../controllers/project").getOne(userId, projectId),
    createOperation: (record) => operationModel().create(record),
    findOperation: (userId, projectId, operationId) => operationModel().findOne({
      _id: operationId, user_id: userId, project_id: projectId, type: "merge",
    }).exec(),
    setCancelled: (userId, projectId, operationId, now) => operationModel().findOneAndUpdate(
      { _id: operationId, user_id: userId, project_id: projectId, type: "merge", status: { $in: ["queued", "processing"] } },
      { $set: { status: "cancelled", cancelled_at: now, finished_at: now } },
      { new: true },
    ).exec(),
    failQueued: (operationId) => operationModel().findOneAndUpdate(
      { _id: operationId, type: "merge", status: "queued" },
      { $set: { status: "failed", finished_at: new Date(), error_code: "VIDEO_MERGE_QUEUE_FAILED" } },
      { new: true },
    ).exec(),
    setQuotaRefunded: (operationId) => operationModel().updateOne(
      { _id: operationId, type: "merge" }, { $set: { quota_refunded: true } },
    ).exec(),
    reserveQuota: async (userId, profile) => {
      if (profile === "premium") return false;
      const { axios, httpsAgent } = await usersClient();
      try {
        await axios.get(`${usersUrl}/${userId}/process/1`, { httpsAgent });
      } catch (error) {
        if (error.response?.status === 701) throw mergeError("VIDEO_MERGE_QUOTA_EXCEEDED", 429);
        throw error;
      }
      return true;
    },
    refundQuota: async (userId) => {
      const { axios, httpsAgent } = await usersClient();
      await axios.post(`${usersUrl}/${userId}/process/refund/1`, null, { httpsAgent });
    },
    enqueue: (operationId) => require("../utils/rabbit_mq").send_rabbit_msg(
      { operationId }, "video_merge",
    ),
    publish: (operation) => require("../utils/project_msg").send_msg_project_op({
      projectId: String(operation.project_id), ownerId: String(operation.user_id),
      op: require("../utils/videoOperationMsg").operationEvent(operation),
    }),
  };
}

function createVideoMergeOperationService(injected = {}) {
  const deps = { ...defaultDependencies(), ...injected };
  const notify = async (operation) => {
    try { await deps.publish(operation); }
    catch (error) { console.error("UC-VID-006: falha na notificação:", error.message); }
  };

  async function createMergeOperation({ userId, projectId, videoIds, profile }) {
    if (!userId || !projectId) throw mergeError("VIDEO_MERGE_UNAUTHORIZED", 403);
    const project = await deps.getProject(userId, projectId);
    if (!project) throw mergeError("VIDEO_MERGE_UNAUTHORIZED", 403);
    const selection = validateMergeSelection({ videoIds, projectVideos: project.videos, profile });
    let quotaReserved = false;
    let operation;
    try {
      quotaReserved = await deps.reserveQuota(userId, profile);
      operation = await deps.createOperation({
        type: "merge", user_id: userId, project_id: projectId,
        source_video_ids: selection.videos.map((video) => video._id),
        total_duration_seconds: selection.totalDurationSeconds,
        status: "queued", progress: 0, quota_reserved: quotaReserved,
      });
      // Publicar na fila apenas depois de existir o registo.
      await deps.enqueue(String(operation._id));
    } catch (error) {
      if (operation) {
        try { await deps.failQueued(String(operation._id)); }
        catch (markError) { console.error("UC-VID-006: falha ao assinalar a operação:", markError.message); }
      }
      if (quotaReserved) {
        try {
          await deps.refundQuota(userId);
          if (operation) await deps.setQuotaRefunded(String(operation._id));
        } catch (refundError) {
          // Não devolver falso sucesso: manter a operação visível para reconciliação.
          console.error("UC-VID-006: reembolso pendente:", refundError.message);
        }
      }
      throw error;
    }
    await notify(operation);
    return operation;
  }

  async function getMergeOperation(userId, projectId, operationId) {
    if (!userId || !projectId || !operationId) throw mergeError("VIDEO_MERGE_NOT_FOUND", 404);
    const operation = await deps.findOperation(userId, projectId, operationId);
    if (!operation) throw mergeError("VIDEO_MERGE_NOT_FOUND", 404);
    return operation;
  }

  async function cancelMergeOperation(userId, projectId, operationId) {
    const now = new Date();
    let operation = await deps.setCancelled(userId, projectId, operationId, now);
    if (!operation) operation = await getMergeOperation(userId, projectId, operationId);
    if (operation.status !== "cancelled") return operation; // Terminal: completed/failed
    // Workers têm de consultar o estado na BD e abortar o FFmpeg (Passo seguinte).
    if (operation.quota_reserved && !operation.quota_refunded) {
      await deps.refundQuota(userId);
      await deps.setQuotaRefunded(String(operation._id));
      operation.quota_refunded = true;
    }
    await notify(operation);
    return operation;
  }

  return { createMergeOperation, getMergeOperation, cancelMergeOperation };
}

module.exports = { createVideoMergeOperationService, publicMergeError };
