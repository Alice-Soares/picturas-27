const crypto = require("crypto");
const fs = require("fs");
const os = require("os");
const path = require("path");
const FormData = require("form-data");
const Project = require("../controllers/project");
const VideoOperation = require("../models/videoOperation");
const { download_video } = require("../utils/videoStorage");
const { post_extracted_image, delete_image } = require("../utils/imageStorage");
const { send_msg_project_op } = require("../utils/project_msg");
const { read_rabbit_msg } = require("../utils/rabbit_mq");
const { operationEvent } = require("../utils/videoOperationMsg");
const { extractFrames } = require("./videoFramePipeline");

const activeProcesses = new Map();

function publish(operation) {
  send_msg_project_op({
    projectId: String(operation.project_id),
    ownerId: String(operation.user_id),
    op: operationEvent(operation),
  });
}

function hashFile(filePath) {
  return new Promise((resolve, reject) => {
    const digest = crypto.createHash("sha256");
    const stream = fs.createReadStream(filePath);
    stream.on("data", (chunk) => digest.update(chunk));
    stream.on("error", reject);
    stream.on("end", () => resolve(digest.digest("hex")));
  });
}

function imageKeyFromResponse(response) {
  const imageKey = response?.data?.data?.imageKey;
  if (!imageKey) throw new Error("VIDEO_FRAME_EXTRACT_FAILED");
  return imageKey.split("/").pop();
}

async function removeUploadedImages(operation) {
  const results = operation.frame_results || [];
  await Promise.all(results.map((result) => delete_image(
    operation.user_id,
    operation.target_project_id || operation.project_id,
    "src",
    result.object_key,
  ).catch(() => {})));
}

async function runFrameExtractionOperation(operationId) {
  const operation = await VideoOperation.findById(operationId);
  if (!operation || operation.type !== "frame_extract" || operation.status !== "queued") return;

  const sourceProject = await Project.getOne(operation.user_id, operation.project_id);
  const source = sourceProject?.videos?.id(operation.source_video_id);
  if (!source) {
    const { failFrameExtractionOperation } = require("./videoOperationService");
    return failFrameExtractionOperation(operation, new Error("VIDEO_FRAME_EXTRACT_NOT_FOUND"));
  }

  const targetProjectId = operation.target_project_id || operation.project_id;
  const targetProject = await Project.getOne(operation.user_id, targetProjectId);
  if (!targetProject) {
    const { failFrameExtractionOperation } = require("./videoOperationService");
    return failFrameExtractionOperation(operation, new Error("VIDEO_FRAME_EXTRACT_DESTINATION_NOT_FOUND"));
  }

  const directory = await fs.promises.mkdtemp(path.join(os.tmpdir(), "picturas-frame-extract-"));
  const input = path.join(directory, "input.mp4");
  activeProcesses.set(String(operationId), directory);
  try {
    const current = await VideoOperation.findOneAndUpdate(
      { _id: operationId, status: "queued" },
      { $set: { status: "processing", started_at: new Date(), progress: 1 } },
      { new: true },
    );
    if (!current) return;
    publish(current);
    await download_video(operation.user_id, operation.project_id, source.object_key, input);

    const framesDirectory = path.join(directory, "frames");
    await fs.promises.mkdir(framesDirectory);
    const frames = await extractFrames(
      input,
      framesDirectory,
      operation.start_seconds,
      operation.end_seconds,
      source.fps,
      { format: "jpeg", maxFrames: operation.max_frames },
    );
    if (frames.length === 0) throw new Error("VIDEO_FRAME_EXTRACT_NO_FRAMES");

    for (let index = 0; index < frames.length; index += 1) {
      const state = await VideoOperation.findById(operationId).select("status");
      if (state?.status === "cancelled") throw new Error("VIDEO_FRAME_EXTRACT_CANCELLED");
      const framePath = frames[index];
      const sha256 = await hashFile(framePath);
      const form = new FormData();
      form.append("file", fs.createReadStream(framePath), {
        filename: path.basename(framePath),
        contentType: "image/jpeg",
      });
      const stored = await post_extracted_image(operation.user_id, targetProjectId, form);
      const objectKey = imageKeyFromResponse(stored);
      const frameResult = {
        object_key: objectKey,
        sha256,
        frame_index: index,
        timestamp_seconds: operation.start_seconds + index / source.fps,
      };
      const updated = await VideoOperation.findOneAndUpdate(
        { _id: operationId, status: "processing" },
        {
          $push: { frame_results: frameResult },
          $set: { extracted_frames: index + 1, progress: Math.min(95, Math.round(((index + 1) / frames.length) * 95)) },
        },
        { new: true },
      );
      if (!updated) throw new Error("VIDEO_FRAME_EXTRACT_CANCELLED");
      publish(updated);
    }

    const latest = await VideoOperation.findById(operationId);
    if (!latest || latest.status === "cancelled") throw new Error("VIDEO_FRAME_EXTRACT_CANCELLED");
    const destination = await Project.getOne(operation.user_id, targetProjectId);
    const references = (latest.frame_results || []).map((result) => ({
      og_uri: `./images/users/${operation.user_id}/projects/${targetProjectId}/src/${result.object_key}`,
      new_uri: `./images/users/${operation.user_id}/projects/${targetProjectId}/src/${result.object_key}`,
      og_img_key: result.object_key,
      og_sha256: result.sha256,
      sourceVideoId: source._id,
      extractionOperationId: operation._id,
      frameIndex: result.frame_index,
      timestampSeconds: result.timestamp_seconds,
      mimeType: "image/jpeg",
    }));
    const updatedProject = await Project.appendImagesIfVersion(
      operation.user_id,
      targetProjectId,
      references,
      destination.version,
    );
    if (!updatedProject) throw new Error("VIDEO_FRAME_EXTRACT_FAILED");
    const completed = await VideoOperation.findOneAndUpdate(
      { _id: operationId, status: "processing" },
      { $set: { status: "completed", progress: 100, finished_at: new Date() } },
      { new: true },
    );
    if (completed) publish(completed);
  } catch (error) {
    const latest = await VideoOperation.findById(operationId);
    if (latest?.status !== "cancelled") {
      const { failFrameExtractionOperation } = require("./videoOperationService");
      await removeUploadedImages(latest || operation);
      await failFrameExtractionOperation(latest || operation, error);
    } else {
      await removeUploadedImages(latest);
    }
  } finally {
    activeProcesses.delete(String(operationId));
    await fs.promises.rm(directory, { recursive: true, force: true });
  }
}

function cancelFrameExtractionProcess(operationId) {
  const directory = activeProcesses.get(operationId);
  if (!directory) return false;
  fs.rm(directory, { recursive: true, force: true }, () => {});
  return true;
}

function startFrameExtractionWorker() {
  read_rabbit_msg("video_frame_extract", (message) => {
    let payload;
    try { payload = JSON.parse(message.content.toString()); } catch (_) { return; }
    if (payload.operationId) runFrameExtractionOperation(payload.operationId).catch((error) => console.error(error.message));
  });
}

module.exports = { startFrameExtractionWorker, runFrameExtractionOperation, cancelFrameExtractionProcess, removeUploadedImages };