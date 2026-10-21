const fs = require("fs");
const path = require("path");
const { v4: uuidv4 } = require("uuid");
const Project = require("../controllers/project");
const VideoOperation = require("../models/videoOperation");
const { download_video, post_video, delete_video } = require("../utils/videoStorage");
const { send_msg_tool, send_msg_project_op } = require("../utils/project_msg");
const { read_rabbit_msg } = require("../utils/rabbit_mq");
const { readVideoMetadata } = require("./videoMetadata");
const { extractFrames, assembleVideo } = require("./videoFramePipeline");

const pendingFrames = new Map();
const activeProcesses = new Map();

function publish(operation) {
  send_msg_project_op({
    projectId: String(operation.project_id),
    ownerId: String(operation.user_id),
    op: {
      operationId: String(operation._id),
      type: operation.type,
      status: operation.status,
      progress: operation.progress || 0,
      resultVideoId: operation.result_video_id ? String(operation.result_video_id) : null,
      errorCode: operation.error_code || null,
    },
  });
}

function processFrame(input, output, tool) {
  return new Promise((resolve, reject) => {
    const messageId = `video-frame-${uuidv4()}`;
    const timeoutMs = Number(process.env.VIDEO_FRAME_TOOL_TIMEOUT_MS || 60_000);
    const timeout = setTimeout(() => {
      pendingFrames.delete(messageId);
      reject(new Error("VIDEO_FRAME_TOOL_TIMEOUT"));
    }, timeoutMs);
    pendingFrames.set(messageId, {
      resolve: (value) => {
        clearTimeout(timeout);
        resolve(value);
      },
      reject: (error) => {
        clearTimeout(timeout);
        reject(error);
      },
    });
    try {
      send_msg_tool(messageId, new Date().toISOString(), input, output, tool.procedure, tool.params);
    } catch (error) {
      clearTimeout(timeout);
      pendingFrames.delete(messageId);
      reject(error);
    }
  });
}

async function handleToolResponse(message) {
  const messageId = message?.correlationId;
  const pending = pendingFrames.get(messageId);
  if (!pending) return false;
  pendingFrames.delete(messageId);
  if (message.status === "error") {
    pending.reject(new Error("VIDEO_FRAME_TOOL_FAILED"));
  } else if (message.output?.type !== "image" || !message.output.imageURI) {
    pending.reject(new Error("VIDEO_FRAME_TOOL_INCOMPATIBLE"));
  } else {
    pending.resolve(message.output.imageURI);
  }
  return true;
}

async function processFrameChain(input, outputDirectory, tools) {
  let current = input;
  for (let index = 0; index < tools.length; index += 1) {
    const output = path.join(outputDirectory, `processed-${String(index).padStart(2, "0")}-${path.basename(input)}`);
    const outputUri = `./${path.relative(path.join(__dirname, ".."), output)}`;
    const returnedUri = await processFrame(`./${path.relative(path.join(__dirname, ".."), current)}`, outputUri, tools[index]);
    current = path.join(__dirname, "..", returnedUri.replace(/^\.\//, ""));
  }
  const finalPath = path.join(outputDirectory, `processed-${path.basename(input)}`);
  await fs.promises.copyFile(current, finalPath);
  return finalPath;
}

async function processWithRetry(processor) {
  let attempts = 0;
  while (attempts < 2) {
    try {
      await processor(attempts + 1);
      return attempts + 1;
    } catch (error) {
      attempts += 1;
      if (attempts >= 2) throw error;
    }
  }
  return attempts;
}

async function runFrameToolOperation(operationId) {
  const operation = await VideoOperation.findById(operationId);
  if (!operation || operation.type !== "frame_tool" || operation.status !== "queued") return;
  const project = await Project.getOne(operation.user_id, operation.project_id);
  const source = project?.videos?.id(operation.source_video_id);
  if (!source) {
    const { failFrameToolOperation } = require("./videoOperationService");
    await failFrameToolOperation(operation, new Error("VIDEO_FRAME_TOOL_NOT_FOUND"));
    return;
  }
  const sharedRoot = path.join(__dirname, "..", "images", "users", String(operation.user_id), "projects", String(operation.project_id), "video-operations");
  await fs.promises.mkdir(sharedRoot, { recursive: true });
  const directory = await fs.promises.mkdtemp(path.join(sharedRoot, `${operationId}-`));
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
    const frames = await extractFrames(input, framesDirectory, operation.start_seconds, operation.end_seconds, operation.output_fps);
    if (frames.length === 0) throw new Error("VIDEO_FRAME_TOOL_FAILED");
    const processedDirectory = path.join(directory, "processed");
    await fs.promises.mkdir(processedDirectory);
    for (let index = 0; index < frames.length; index += 1) {
      const state = await VideoOperation.findById(operationId).select("status");
      if (state?.status === "cancelled") throw new Error("VIDEO_FRAME_TOOL_CANCELLED");
      const attempt = await processWithRetry(() => processFrameChain(frames[index], processedDirectory, operation.tools));
      const updated = await VideoOperation.findOneAndUpdate(
        { _id: operationId, status: "processing" },
        { $set: { progress: Math.min(95, Math.round(((index + 1) / frames.length) * 95)), frame_attempts: attempt } },
        { new: true },
      );
      if (updated) publish(updated);
    }
    const output = path.join(directory, `${operationId}.mp4`);
    await assembleVideo(input, processedDirectory, output, operation.start_seconds, operation.end_seconds, operation.output_fps);
    const metadata = await readVideoMetadata({ path: output, originalname: source.name });
    const form = new (require("form-data"))();
    form.append("video", fs.createReadStream(output), { filename: source.name, contentType: "video/mp4" });
    const stored = await post_video(operation.user_id, operation.project_id, form);
    const objectKey = stored.data.data.imageKey;
    const latest = await VideoOperation.findById(operationId).select("status");
    if (latest?.status === "cancelled") {
      await delete_video(operation.user_id, operation.project_id, objectKey);
      return;
    }
    const finalizing = await VideoOperation.findOneAndUpdate(
      { _id: operationId, status: "processing", commit_locked: { $ne: true } },
      { $set: { commit_locked: true } },
      { new: true },
    );
    if (!finalizing) {
      await delete_video(operation.user_id, operation.project_id, objectKey);
      return;
    }
    const updatedProject = await Project.appendVideo(operation.user_id, operation.project_id, {
      user_id: operation.user_id,
      project_id: operation.project_id,
      sourceVideoId: source._id,
      stage: "video-src",
      object_key: objectKey,
      name: `${path.parse(source.name).name}-frame-tool.mp4`,
      ...metadata,
    });
    if (!updatedProject) {
      await delete_video(operation.user_id, operation.project_id, objectKey);
      throw new Error("VIDEO_FRAME_TOOL_FAILED");
    }
    const result = updatedProject.videos[updatedProject.videos.length - 1];
    const completed = await VideoOperation.findOneAndUpdate(
      { _id: operationId, status: "processing", commit_locked: true },
      { $set: { status: "completed", progress: 100, finished_at: new Date(), result_video_id: result?._id || null } },
      { new: true },
    );
    if (completed) publish(completed);
  } catch (error) {
    if (error.message !== "VIDEO_FRAME_TOOL_CANCELLED") {
      const { failFrameToolOperation } = require("./videoOperationService");
      await failFrameToolOperation(operation, error);
    }
  } finally {
    activeProcesses.delete(String(operationId));
    await fs.promises.rm(directory, { recursive: true, force: true });
  }
}

function cancelFrameToolProcess(operationId) {
  const directory = activeProcesses.get(operationId);
  if (!directory) return false;
  fs.rm(directory, { recursive: true, force: true }, () => {});
  return true;
}

function startFrameToolWorker() {
  read_rabbit_msg("video_frame_tool", (message) => {
    let payload;
    try { payload = JSON.parse(message.content.toString()); } catch (_) { return; }
    if (payload.operationId) runFrameToolOperation(payload.operationId).catch((error) => console.error(error.message));
  });
}

module.exports = { startFrameToolWorker, runFrameToolOperation, handleToolResponse, cancelFrameToolProcess, processWithRetry };
