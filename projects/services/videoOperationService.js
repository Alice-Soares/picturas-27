const axios = require("axios");
const https = require("https");
const { v4: uuidv4 } = require("uuid");
const Project = require("../controllers/project");
const VideoOperation = require("../models/videoOperation");
const { validateTrimInterval } = require("./videoTrimValidation");
const { publicTrimError } = require("./videoTrimErrors");
const { assertTransition } = require("./videoOperationState");
const { operationEvent } = require("../utils/videoOperationMsg");
const { send_msg_project_op } = require("../utils/project_msg");
const { send_rabbit_msg } = require("../utils/rabbit_mq");

const usersUrl = "https://users:10001";
const httpsAgent = new https.Agent({ rejectUnauthorized: false });

async function reserveQuota(userId, profile) {
  if (profile === "premium") return false;
  try {
    await axios.get(`${usersUrl}/${userId}/process/1`, { httpsAgent });
    return true;
  } catch (error) {
    if (error.response?.status === 701) {
      const quotaError = new Error("VIDEO_TRIM_QUOTA_EXCEEDED");
      quotaError.status = 429;
      throw quotaError;
    }
    throw error;
  }
}

function publish(operation, overrides = {}) {
  send_msg_project_op({
    projectId: String(operation.project_id),
    ownerId: String(operation.user_id),
    op: operationEvent(operation, overrides),
  });
}

async function refundQuota(operation) {
  if (!operation.quota_reserved || operation.quota_refunded) return;
  await axios.post(`${usersUrl}/${operation.user_id}/process/refund/1`, null, { httpsAgent });
  operation.quota_refunded = true;
  await operation.save();
}

async function createTrimOperation({ userId, projectId, videoId, startSeconds, endSeconds, profile }) {
  const project = await Project.getOne(userId, projectId);
  if (!project) {
    const error = new Error("VIDEO_TRIM_UNAUTHORIZED");
    error.status = 403;
    throw error;
  }
  const video = (project.videos || []).id(videoId);
  if (!video) {
    const error = new Error("VIDEO_TRIM_NOT_FOUND");
    error.status = 404;
    throw error;
  }
  const interval = validateTrimInterval({
    startSeconds: Number(startSeconds),
    endSeconds: Number(endSeconds),
    duration: video.duration,
  });
  const quotaReserved = await reserveQuota(userId, profile);
  const operation = await VideoOperation.create({
    type: "trim",
    user_id: userId,
    project_id: projectId,
    source_video_id: video._id,
    start_seconds: interval.startSeconds,
    end_seconds: interval.endSeconds,
    quota_reserved: quotaReserved,
  });
  publish(operation);
  send_rabbit_msg({ operationId: String(operation._id) }, "video_trim");
  return operation;
}

async function getOperation(userId, projectId, operationId) {
  const operation = await VideoOperation.findOne({
    _id: operationId,
    user_id: userId,
    project_id: projectId,
  }).exec();
  if (!operation) {
    const error = new Error("VIDEO_TRIM_NOT_FOUND");
    error.status = 404;
    throw error;
  }
  return operation;
}

async function cancelTrimOperation(userId, projectId, operationId) {
  const operation = await getOperation(userId, projectId, operationId);
  if (["completed", "failed", "cancelled"].includes(operation.status)) return operation;
  assertTransition(operation.status, "cancelled");
  operation.status = "cancelled";
  operation.cancelled_at = new Date();
  operation.finished_at = operation.cancelled_at;
  await operation.save();
  try {
    require("./videoTrimWorker").cancelTrimProcess(String(operation._id));
  } catch (error) {
    console.error("Failed to stop video trim process:", error.message);
  }
  await refundQuota(operation);
  publish(operation);
  return operation;
}

async function failOperation(operation, error) {
  const current = await VideoOperation.findById(operation._id);
  if (!current || ["completed", "cancelled", "failed"].includes(current.status)) return current;
  current.status = "failed";
  current.error_code = publicTrimError(error).code;
  current.error_message = publicTrimError(error).message;
  current.finished_at = new Date();
  await current.save();
  await refundQuota(current);
  publish(current);
  return current;
}

module.exports = {
  createTrimOperation,
  getOperation,
  cancelTrimOperation,
  failOperation,
  startTrimWorker: () => require("./videoTrimWorker").startTrimWorker(),
};
