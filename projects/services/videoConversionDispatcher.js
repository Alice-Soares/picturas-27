const fs = require("fs");
const os = require("os");
const path = require("path");
const { v4: uuidv4 } = require("uuid");
const VideoOperation = require("../models/videoOperation");
const Project = require("../controllers/project");
const { download_video, post_video, delete_video } = require("../utils/videoStorage");
const { send_rabbit_msg } = require("../utils/rabbit_mq");
const { conversionRequest } = require("../utils/videoConversionMsg");
const { send_msg_project_op } = require("../utils/project_msg");
const { operationEvent } = require("../utils/videoOperationMsg");

const pending = new Map();
const activeProcesses = new Map();

function publish(operation) {
  send_msg_project_op({
    projectId: String(operation.project_id),
    ownerId: String(operation.user_id),
    op: operationEvent(operation),
  });
}

async function dispatchConversion(operation, source) {
  const directory = await fs.promises.mkdtemp(path.join("/app/images", "picturas-conversion-"));
  const inputPath = path.join(directory, "input");
  const outputPath = path.join(directory, `output.${operation.output.outputContainer}`);
  await download_video(operation.user_id, operation.project_id, source.object_key, inputPath);
  activeProcesses.set(String(operation._id), directory);

  const message = conversionRequest({ operation, inputVideoURI: inputPath, outputVideoURI: outputPath });
  send_rabbit_msg(message, "video_conversion");
  const timeout = setTimeout(async () => {
    const entry = pending.get(String(operation._id));
    if (!entry) return;
    pending.delete(String(operation._id));
    await cleanup(directory);
    await require("./videoOperationService").failConversionOperation(operation, new Error("VIDEO_CONVERSION_FAILED"));
  }, Number(process.env.VIDEO_CONVERSION_TIMEOUT_MS || 30 * 60 * 1000));
  pending.set(String(operation._id), { directory, outputPath, source, operation, timeout });
}

async function handleToolResponse(message) {
  const entry = pending.get(String(message.correlationId));
  if (!entry) return false;
  const operation = await VideoOperation.findById(message.correlationId);
  if (!operation || ["cancelled", "failed", "completed"].includes(operation.status)) {
    clearTimeout(entry.timeout);
    await cleanup(entry.directory);
    pending.delete(String(message.correlationId));
    return true;
  }
  if (message.status === "processing") {
    operation.status = "processing";
    operation.progress = Math.max(operation.progress || 1, Number(message.progress) || 1);
    await operation.save();
    publish(operation);
    return true;
  }
  try {
    clearTimeout(entry.timeout);
    if (message.status === "error") throw new Error(message.error?.code || "VIDEO_CONVERSION_FAILED");
    const metadata = message.output?.metadata;
    if (!metadata) throw new Error("VIDEO_CONVERSION_FAILED");
    const form = new (require("form-data"))();
    form.append("video", fs.createReadStream(entry.outputPath), {
      filename: `converted.${operation.output.outputContainer}`,
      contentType: "video/mp4",
    });
    const stored = await post_video(operation.user_id, operation.project_id, form);
    const project = await Project.getOne(operation.user_id, operation.project_id);
    const reference = {
      user_id: operation.user_id,
      project_id: operation.project_id,
      sourceVideoId: entry.source._id,
      stage: "video-src",
      object_key: stored.data.data.imageKey,
      name: `${path.parse(entry.source.name).name}-converted.${operation.output.outputContainer}`,
      ...metadata,
    };
    const updatedProject = await Project.appendVideoIfVersion(
      operation.user_id, operation.project_id, reference, project.version,
    );
    if (!updatedProject) throw new Error("PROJECT_VERSION_CONFLICT");
    operation.status = "completed";
    operation.progress = 100;
    operation.result_video_id = updatedProject.videos.at(-1)?._id || null;
    operation.finished_at = new Date();
    await operation.save();
    publish(operation);
  } catch (error) {
    await require("./videoOperationService").failConversionOperation(operation, error);
  } finally {
    await cleanup(entry.directory);
    pending.delete(String(message.correlationId));
    activeProcesses.delete(String(message.correlationId));
  }
  return true;
}

async function cleanup(directory) {
  if (directory) await fs.promises.rm(directory, { recursive: true, force: true });
}

function cancelConversion(operationId) {
  const directory = activeProcesses.get(String(operationId));
  const entry = pending.get(String(operationId));
  if (entry) {
    clearTimeout(entry.timeout);
    pending.delete(String(operationId));
  }
  if (!directory) return false;
  cleanup(directory).catch(() => {});
  activeProcesses.delete(String(operationId));
  return true;
}

module.exports = { dispatchConversion, handleToolResponse, cancelConversion };
