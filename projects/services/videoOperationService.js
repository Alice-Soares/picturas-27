const axios = require("axios");
const fs = require("fs");
const https = require("https");
const { v4: uuidv4 } = require("uuid");
const Project = require("../controllers/project");
const VideoOperation = require("../models/videoOperation");
const { validateTrimInterval } = require("./videoTrimValidation");
const { publicTrimError } = require("./videoTrimErrors");
const { validateTools, validateFrameInterval } = require("./videoFrameToolValidation");
const { publicFrameToolError } = require("./videoFrameToolErrors");
const { validateExtraction } = require("./videoFrameExtractionValidation");
const { publicFrameExtractionError } = require("./videoFrameExtractionErrors");
const { publicConversionError } = require("./videoConversionErrors");
const { operationEvent } = require("../utils/videoOperationMsg");
const { send_msg_project_op } = require("../utils/project_msg");
const { send_rabbit_msg } = require("../utils/rabbit_mq");
const {
  conversionOptionsResponse,
  validateConversionOptions,
  estimateOutputSize,
} = require("./videoConversionValidation");
const { dispatchConversion, cancelConversion } = require("./videoConversionDispatcher");
const { dispatchAudio, cancelAudio } = require("./videoAudioDispatcher");
const { validateReplacement } = require("./videoAudioValidation");

const usersUrl = "https://users:10001";
const httpsAgent = new https.Agent({ rejectUnauthorized: false });

async function reserveQuota(userId, profile, quotaErrorCode = "VIDEO_TRIM_QUOTA_EXCEEDED") {
  if (profile === "premium") return false;
  if (profile === "anonymous") {
    const error = new Error("VIDEO_ANONYMOUS_NOT_ALLOWED");
    error.status = 403;
    throw error;
  }
  try {
    await axios.get(`${usersUrl}/${userId}/process/1`, { httpsAgent });
    return true;
  } catch (error) {
    if (error.response?.status === 701) {
      const quotaError = new Error(quotaErrorCode);
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

async function enqueueOperation(operation, queue) {
  if (await send_rabbit_msg({ operationId: String(operation._id) }, queue)) return;
  const failed = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: "queued" },
    { $set: {
      status: "failed",
      error_code: "VIDEO_OPERATION_QUEUE_UNAVAILABLE",
      error_message: "The processing service is unavailable. Please try again.",
      finished_at: new Date(),
    } },
    { new: true },
  );
  if (failed) {
    await refundQuota(failed);
    publish(failed);
  }
  const error = new Error("VIDEO_OPERATION_QUEUE_UNAVAILABLE");
  error.status = 503;
  throw error;
}

async function refundQuota(operation) {
  if (!operation.quota_reserved) return;
  const claimed = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, quota_reserved: true, quota_refunded: false },
    { $set: { quota_refunded: true } },
    { new: true },
  );
  if (!claimed) return;
  try {
    await axios.post(`${usersUrl}/${claimed.user_id}/process/refund/1`, null, { httpsAgent });
  } catch (error) {
    await VideoOperation.updateOne(
      { _id: claimed._id, quota_refunded: true },
      { $set: { quota_refunded: false } },
    );
    throw error;
  }
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
  const quotaReserved = await reserveQuota(userId, profile, "VIDEO_TRIM_QUOTA_EXCEEDED");
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
  await enqueueOperation(operation, "video_trim");
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
  const cancelledAt = new Date();
  const cancelled = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] }, commit_locked: { $ne: true } },
    { $set: { status: "cancelled", cancelled_at: cancelledAt, finished_at: cancelledAt } },
    { new: true },
  );
  if (!cancelled) return getOperation(userId, projectId, operationId);
  try {
    require("./videoTrimWorker").cancelTrimProcess(String(operation._id));
  } catch (error) {
    console.error("Failed to stop video trim process:", error.message);
  }
  await refundQuota(cancelled);
  publish(cancelled);
  return cancelled;
}

async function failOperation(operation, error) {
  const publicError = publicTrimError(error);
  const current = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] } },
    { $set: { status: "failed", error_code: publicError.code, error_message: publicError.message, finished_at: new Date() } },
    { new: true },
  );
  if (!current) return VideoOperation.findById(operation._id);
  await refundQuota(current);
  publish(current);
  return current;
}

async function getVideoConversionOptions({ userId, projectId, videoId, profile }) {
  if (profile === "anonymous") {
    const error = new Error("VIDEO_ANONYMOUS_NOT_ALLOWED");
    error.status = 403;
    throw error;
  }
  const project = await Project.getOne(userId, projectId);
  if (!project) {
    const error = new Error("VIDEO_CONVERSION_UNAUTHORIZED");
    error.status = 403;
    throw error;
  }
  const video = (project.videos || []).id(videoId);
  if (!video) {
    const error = new Error("VIDEO_CONVERSION_NOT_FOUND");
    error.status = 404;
    throw error;
  }
  return conversionOptionsResponse(video, profile);
}

async function createVideoConversionOperation({
  userId, projectId, videoId, options, profile,
}) {
  const project = await Project.getOne(userId, projectId);
  if (!project) {
    const error = new Error("VIDEO_CONVERSION_UNAUTHORIZED");
    error.status = 403;
    throw error;
  }
  const source = (project.videos || []).id(videoId);
  if (!source) {
    const error = new Error("VIDEO_CONVERSION_NOT_FOUND");
    error.status = 404;
    throw error;
  }
  const output = validateConversionOptions(options, profile);
  output.estimatedSize = estimateOutputSize({
    duration: source.duration,
    width: output.outputWidth,
    height: output.outputHeight,
    bitrate: options.bitrate,
  });
  const quotaReserved = await reserveQuota(
    userId,
    profile,
    "VIDEO_CONVERSION_QUOTA_EXCEEDED",
  );
  const operation = await VideoOperation.create({
    type: "conversion",
    user_id: userId,
    project_id: projectId,
    source_video_id: source._id,
    start_seconds: 0,
    end_seconds: source.duration,
    output,
    quota_reserved: quotaReserved,
  });
  publish(operation);
  dispatchConversion(operation, source).catch((error) => failConversionOperation(operation, error));
  return operation;
}

async function failConversionOperation(operation, error) {
  const publicError = publicConversionError(error);
  const current = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] } },
    { $set: { status: "failed", error_code: publicError.code, error_message: publicError.message, finished_at: new Date() } },
    { new: true },
  );
  if (!current) return VideoOperation.findById(operation._id);
  await refundQuota(current);
  publish(current);
  return current;
}

async function cancelVideoConversionOperation(userId, projectId, operationId) {
  const operation = await getOperation(userId, projectId, operationId);
  if (operation.type !== "conversion" ||
      ["completed", "failed", "cancelled"].includes(operation.status)) {
    return operation;
  }
  const cancelledAt = new Date();
  const cancelled = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] }, commit_locked: { $ne: true } },
    { $set: { status: "cancelled", cancelled_at: cancelledAt, finished_at: cancelledAt } },
    { new: true },
  );
  if (!cancelled) return getOperation(userId, projectId, operationId);
  await cancelConversion(operationId);
  await refundQuota(cancelled);
  publish(cancelled);
  return cancelled;
}

async function createAudioOperation({ userId, projectId, videoId, action, profile, file, startSeconds, endSeconds }) {
  const project = await Project.getOne(userId, projectId);
  if (!project) { const e = new Error("VIDEO_AUDIO_UNAUTHORIZED"); e.status = 403; throw e; }
  const source = (project.videos || []).id(videoId);
  if (!source) { const e = new Error("VIDEO_AUDIO_NOT_FOUND"); e.status = 404; throw e; }
  if (!["remove", "replace", "extract"].includes(action)) throw new Error("VIDEO_AUDIO_INVALID");
  if (action !== "replace" && !source.audioCodec) throw new Error("VIDEO_AUDIO_NO_TRACK");
  let audio = null;
  if (action === "replace") audio = await validateReplacement(file, startSeconds, endSeconds);
  const quotaReserved = await reserveQuota(userId, profile, "VIDEO_AUDIO_QUOTA_EXCEEDED");
  let operation;
  try {
    operation = await VideoOperation.create({ type: "audio", audio_action: action, user_id: userId, project_id: projectId, source_video_id: source._id, start_seconds: 0, end_seconds: source.duration, audio_start_seconds: audio?.startSeconds ?? null, audio_end_seconds: audio?.endSeconds ?? null, quota_reserved: quotaReserved });
    publish(operation);
    dispatchAudio(operation, source, action === "replace" ? file : null).catch((error) => failAudioOperation(operation, error));
    return operation;
  } catch (error) {
    if (quotaReserved) await axios.post(`${usersUrl}/${userId}/process/refund/1`, null, { httpsAgent }).catch(() => {});
    throw error;
  }
}

async function failAudioOperation(operation, error) {
  const current = await VideoOperation.findById(operation._id);
  if (!current || ["completed", "cancelled", "failed"].includes(current.status)) return current;
  const safe = require("./videoAudioErrors").publicAudioError(error);
  current.status = "failed"; current.error_code = safe.code; current.error_message = safe.code; current.finished_at = new Date();
  await current.save(); await refundQuota(current); publish(current); return current;
}

async function cancelAudioOperation(userId, projectId, operationId) {
  const operation = await getOperation(userId, projectId, operationId);
  if (operation.type !== "audio" || ["completed", "failed", "cancelled"].includes(operation.status)) return operation;
  if (cancelAudio(operationId) === "committing") return operation;
  assertTransition(operation.status, "cancelled"); operation.status = "cancelled"; operation.cancelled_at = new Date(); operation.finished_at = operation.cancelled_at; await operation.save();
  await refundQuota(operation); publish(operation); return operation;
}

async function createFrameToolOperation({ userId, projectId, videoId, tools, startSeconds, endSeconds, outputFps, profile }) {
  const project = await Project.getOne(userId, projectId);
  if (!project) {
    const error = new Error("VIDEO_FRAME_TOOL_UNAUTHORIZED");
    error.status = 403;
    throw error;
  }

  const video = (project.videos || []).id(videoId);
  if (!video) {
    const error = new Error("VIDEO_FRAME_TOOL_NOT_FOUND");
    error.status = 404;
    throw error;
  }
  const normalizedTools = validateTools(tools);
  const interval = validateFrameInterval({
    startSeconds,
    endSeconds,
    outputFps,
    duration: video.duration,
    sourceFps: video.fps,
  });
  const quotaReserved = await reserveQuota(userId, profile, "VIDEO_FRAME_TOOL_QUOTA_EXCEEDED");
  const operation = await VideoOperation.create({
    type: "frame_tool",
    user_id: userId,
    project_id: projectId,
    source_video_id: video._id,
    start_seconds: interval.startSeconds,
    end_seconds: interval.endSeconds,
    output_fps: interval.outputFps,
    tools: normalizedTools,
    quota_reserved: quotaReserved,
  });
  publish(operation);
  await enqueueOperation(operation, "video_frame_tool");
  return operation;
}

async function cancelFrameToolOperation(userId, projectId, operationId) {
  const operation = await getOperation(userId, projectId, operationId);
  if (operation.type !== "frame_tool") return operation;
  if (["completed", "failed", "cancelled"].includes(operation.status)) return operation;
  const cancelledAt = new Date();
  const cancelled = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] } },
    { $set: { status: "cancelled", cancelled_at: cancelledAt, finished_at: cancelledAt } },
    { new: true },
  );
  if (!cancelled) return getOperation(userId, projectId, operationId);
  try {
    require("./videoFrameToolWorker").cancelFrameToolProcess(String(operation._id));
  } catch (error) {
    console.error("Failed to stop video frame tool process:", error.message);
  }
  await refundQuota(cancelled);
  publish(cancelled);
  return cancelled;
}

async function failFrameToolOperation(operation, error) {
  const publicError = publicFrameToolError(error);
  const current = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] } },
    { $set: { status: "failed", error_code: publicError.code, error_message: publicError.message, finished_at: new Date() } },
    { new: true },
  );
  if (!current) return VideoOperation.findById(operation._id);
  await refundQuota(current);
  publish(current);
  return current;
}

async function createFrameExtractionOperation({
  userId,
  projectId,
  videoId,
  targetProjectId,
  startSeconds,
  endSeconds,
  maxFrames,
  outputFormat,
  profile,
}) {
  const project = await Project.getOne(userId, projectId);
  if (!project) {
    const error = new Error("VIDEO_FRAME_EXTRACT_UNAUTHORIZED");
    error.status = 403;
    throw error;
  }
  const video = (project.videos || []).id(videoId);
  if (!video) {
    const error = new Error("VIDEO_FRAME_EXTRACT_NOT_FOUND");
    error.status = 404;
    throw error;
  }
  const destinationId = targetProjectId || projectId;
  const destination = await Project.getOne(userId, destinationId);
  if (!destination) {
    const error = new Error("VIDEO_FRAME_EXTRACT_DESTINATION_NOT_FOUND");
    error.status = 404;
    throw error;
  }
  if (video.videoCodec && video.videoCodec !== "h264") {
    const error = new Error("VIDEO_FRAME_EXTRACT_CODEC_UNSUPPORTED");
    error.status = 400;
    throw error;
  }
  if (Number.isFinite(Number(video.size)) && fs.promises.statfs) {
    const storage = await fs.promises.statfs("/tmp");
    const availableBytes = storage.bavail * storage.bsize;
    if (availableBytes < Number(video.size)) {
      const error = new Error("VIDEO_FRAME_EXTRACT_STORAGE_INSUFFICIENT");
      error.status = 507;
      throw error;
    }
  }
  const extraction = validateExtraction({
    startSeconds,
    endSeconds,
    duration: video.duration,
    sourceFps: video.fps,
    maxFrames,
    profile,
    outputFormat,
  });
  const quotaReserved = await reserveQuota(userId, profile, "VIDEO_FRAME_EXTRACT_QUOTA_EXCEEDED");
  const operation = await VideoOperation.create({
    type: "frame_extract",
    user_id: userId,
    project_id: projectId,
    target_project_id: destination._id,
    source_video_id: video._id,
    start_seconds: extraction.startSeconds,
    end_seconds: extraction.endSeconds,
    max_frames: extraction.maxFrames,
    estimated_frames: extraction.estimatedFrames,
    output_format: extraction.outputFormat,
    quota_reserved: quotaReserved,
  });
  publish(operation);
  await enqueueOperation(operation, "video_frame_extract");
  return operation;
}

async function cancelFrameExtractionOperation(userId, projectId, operationId) {
  const operation = await getOperation(userId, projectId, operationId);
  if (operation.type !== "frame_extract") return operation;
  if (["completed", "failed", "cancelled"].includes(operation.status)) return operation;
  const cancelledAt = new Date();
  const cancelled = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] }, commit_locked: { $ne: true } },
    { $set: { status: "cancelled", cancelled_at: cancelledAt, finished_at: cancelledAt } },
    { new: true },
  );
  if (!cancelled) return getOperation(userId, projectId, operationId);
  try {
    require("./videoFrameExtractionWorker").cancelFrameExtractionProcess(String(operation._id));
  } catch (error) {
    console.error("Failed to stop frame extraction process:", error.message);
  }
  await refundQuota(cancelled);
  publish(cancelled);
  return cancelled;
}

async function failFrameExtractionOperation(operation, error) {
  const publicError = publicFrameExtractionError(error);
  const current = await VideoOperation.findOneAndUpdate(
    { _id: operation._id, status: { $in: ["queued", "processing"] } },
    { $set: { status: "failed", error_code: publicError.code, error_message: publicError.message, finished_at: new Date() } },
    { new: true },
  );
  if (!current) return VideoOperation.findById(operation._id);
  await refundQuota(current);
  publish(current);
  return current;
}

module.exports = {
  createTrimOperation,
  getOperation,
  cancelTrimOperation,
  failOperation,
  createFrameToolOperation,
  cancelFrameToolOperation,
  failFrameToolOperation,
  createFrameExtractionOperation,
  cancelFrameExtractionOperation,
  failFrameExtractionOperation,
  getVideoConversionOptions,
  createVideoConversionOperation,
  failConversionOperation,
  cancelVideoConversionOperation,
  createAudioOperation,
  failAudioOperation,
  cancelAudioOperation,
  startTrimWorker: () => require("./videoTrimWorker").startTrimWorker(),
  startFrameToolWorker: () => require("./videoFrameToolWorker").startFrameToolWorker(),
  startFrameExtractionWorker: () => require("./videoFrameExtractionWorker").startFrameExtractionWorker(),
};
