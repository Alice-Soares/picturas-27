const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawn } = require("child_process");
const Project = require("../controllers/project");
const VideoOperation = require("../models/videoOperation");
const { download_video, post_video, delete_video } = require("../utils/videoStorage");
const { readVideoMetadata } = require("./videoMetadata");
const { send_msg_project_op } = require("../utils/project_msg");
const { operationEvent } = require("../utils/videoOperationMsg");
const { read_rabbit_msg } = require("../utils/rabbit_mq");
const activeProcesses = new Map();

function publish(operation, overrides = {}) {
  send_msg_project_op({
    projectId: String(operation.project_id),
    ownerId: String(operation.user_id),
    op: operationEvent(operation, overrides),
  });
}

function executeFfmpeg(input, output, start, duration, onProgress) {
  return new Promise((resolve, reject) => {
    const child = spawn("ffmpeg", [
      "-y", "-ss", String(start), "-i", input, "-t", String(duration),
      "-c", "copy", "-movflags", "+faststart", output,
    ], { stdio: ["ignore", "ignore", "pipe"] });
    let stderr = "";
    child.stderr.on("data", (chunk) => {
      stderr += chunk.toString();
      onProgress();
    });
    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) return resolve();
      reject(new Error(`FFMPEG_FAILED:${stderr.slice(-200)}`));
    });
    activeProcesses.set(output, child);
  });
}

function cancelTrimProcess(operationId) {
  for (const [output, child] of activeProcesses.entries()) {
    if (output.endsWith(`/${operationId}.mp4`)) {
      child.kill("SIGTERM");
      return true;
    }
  }
  return false;
}

async function runTrimOperation(operationId) {
  const operation = await VideoOperation.findById(operationId);
  if (!operation || operation.status !== "queued") return;
  const project = await Project.getOne(operation.user_id, operation.project_id);
  const source = project?.videos?.id(operation.source_video_id);
  if (!source) {
  const { failOperation } = require("./videoOperationService");
  return failOperation(operation, new Error("VIDEO_TRIM_NOT_FOUND"));
  }

  const directory = await fs.promises.mkdtemp(path.join(os.tmpdir(), "picturas-trim-"));
  const input = path.join(directory, "input.mp4");
  let lastProgress = 0;
  try {
    const current = await VideoOperation.findOneAndUpdate(
      { _id: operationId, status: "queued" },
      { $set: { status: "processing", started_at: new Date(), progress: 1 } },
      { new: true },
    );
    if (!current) return;
    publish(current);
    await download_video(operation.user_id, operation.project_id, source.object_key, input);
    const checkCancelled = async () => {
      const state = await VideoOperation.findById(operationId).select("status");
      if (state?.status === "cancelled") throw new Error("VIDEO_TRIM_CANCELLED");
    };
    await checkCancelled();
    const processOutput = path.join(directory, `${operationId}.mp4`);
    await executeFfmpeg(input, processOutput, operation.start_seconds, operation.end_seconds - operation.start_seconds, () => {
      const now = Date.now();
      if (now - lastProgress > 5000) {
        lastProgress = now;
        VideoOperation.findOneAndUpdate(
          { _id: operationId, status: "processing" },
          { $set: { progress: Math.min(95, (operation.progress || 1) + 1) } },
          { new: true },
        ).then((updated) => { if (updated) publish(updated); }).catch(() => {});
      }
    });
    await checkCancelled();
    const metadata = await readVideoMetadata({ path: processOutput, originalname: source.name });
    const form = new (require("form-data"))();
    form.append("video", fs.createReadStream(processOutput), { filename: source.name, contentType: "video/mp4" });
    const stored = await post_video(operation.user_id, operation.project_id, form);
    const storedObjectKey = stored.data.data.imageKey;
    const reference = {
      user_id: operation.user_id,
      project_id: operation.project_id,
      sourceVideoId: source._id,
      stage: "video-src",
      object_key: storedObjectKey,
      name: `${path.parse(source.name).name}-trim.mp4`,
      ...metadata,
    };
    const latest = await VideoOperation.findById(operationId).select("status");
    if (latest?.status === "cancelled") {
      await delete_video(operation.user_id, operation.project_id, storedObjectKey);
      return;
    }
    const finalizing = await VideoOperation.findOneAndUpdate(
      { _id: operationId, status: "processing", commit_locked: { $ne: true } },
      { $set: { commit_locked: true } },
      { new: true },
    );
    if (!finalizing) {
      await delete_video(operation.user_id, operation.project_id, storedObjectKey);
      return;
    }
    const updatedProject = await Project.appendVideo(
      operation.user_id,
      operation.project_id,
      reference,
    );
    if (!updatedProject) {
      await delete_video(operation.user_id, operation.project_id, storedObjectKey);
      throw new Error("PROJECT_VERSION_CONFLICT");
    }
    const result = updatedProject.videos[updatedProject.videos.length - 1];
    const completed = await VideoOperation.findOneAndUpdate(
      { _id: operationId, status: "processing", commit_locked: true },
      { $set: { status: "completed", progress: 100, finished_at: new Date(), result_video_id: result?._id || null } },
      { new: true },
    );
    if (completed) publish(completed);
  } catch (error) {
    if (error.message !== "VIDEO_TRIM_CANCELLED") {
      const { failOperation } = require("./videoOperationService");
      await failOperation(operation, error);
    }
  } finally {
    activeProcesses.delete(path.join(directory, `${operationId}.mp4`));
    await fs.promises.rm(directory, { recursive: true, force: true });
  }
}

function startTrimWorker() {
  read_rabbit_msg("video_trim", (message) => {
    let payload;
    try {
      payload = JSON.parse(message.content.toString());
    } catch (error) {
      console.error("Invalid video trim queue message:", error.message);
      return;
    }
    if (!payload.operationId) return;
    runTrimOperation(payload.operationId).catch((error) => {
      console.error("Video trim worker failed:", error.message);
    });
  });
}

module.exports = { runTrimOperation, cancelTrimProcess, startTrimWorker };
