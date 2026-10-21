const fs = require("fs");
const path = require("path");
const VideoOperation = require("../models/videoOperation");
const Project = require("../controllers/project");
const { post_video, delete_video } = require("../utils/videoStorage");
const { download_content } = require("../utils/imageStorage");
const { send_rabbit_msg } = require("../utils/rabbit_mq");
const { AUDIO_QUEUE, audioRequest } = require("../utils/videoAudioMsg");
const { operationEvent } = require("../utils/videoOperationMsg");
const { send_msg_project_op } = require("../utils/project_msg");
const pending = new Map();

function publish(op) { send_msg_project_op({ projectId: String(op.project_id), ownerId: String(op.user_id), op: operationEvent(op) }); }
async function cleanup(dir) { if (dir) await fs.promises.rm(dir, { recursive: true, force: true }); }

async function dispatchAudio(operation, source, replacementFile) {
  const dir = fs.mkdtempSync(path.join("/app/images", "picturas-audio-"));
  const input = path.join(dir, "input.mp4"), output = path.join(dir, operation.audio_action === "extract" ? "output.m4a" : "output.mp4");
  const replacement = replacementFile ? path.join(dir, `replacement.${String(replacementFile.originalname).split(".").pop().toLowerCase()}`) : null;
  try {
    if (replacement) fs.copyFileSync(replacementFile.path, replacement);
    const timeout = setTimeout(async () => {
      const entry = pending.get(String(operation._id)); if (!entry) return;
      pending.delete(String(operation._id)); await cleanup(dir);
      await require("./videoOperationService").failAudioOperation(operation, new Error("VIDEO_AUDIO_FAILED"));
    }, Number(process.env.VIDEO_AUDIO_TIMEOUT_MS || 30 * 60 * 1000));
    pending.set(String(operation._id), { dir, input, output, replacement, source, operation, timeout, committing: false });
    await download_content(operation.user_id, operation.project_id, "video-src", source.object_key, input);
    if (!pending.has(String(operation._id))) return;
    send_rabbit_msg(audioRequest({ operation, inputVideoURI: input, replacementAudioURI: replacement, outputURI: output }), AUDIO_QUEUE);
  } catch (error) { const entry = pending.get(String(operation._id)); if (entry) clearTimeout(entry.timeout); pending.delete(String(operation._id)); await cleanup(dir); throw error; }
}

async function handleToolResponse(message) {
  const id = String(message.correlationId || ""), entry = pending.get(id);
  if (!entry) return false;
  const op = await VideoOperation.findById(id);
  if (!op || ["cancelled", "failed", "completed"].includes(op.status)) { clearTimeout(entry.timeout); pending.delete(id); await cleanup(entry.dir); return true; }
  if (message.status === "processing") { op.status = "processing"; op.progress = Math.max(op.progress || 0, Number(message.progress) || 1); await op.save(); publish(op); return true; }
  clearTimeout(entry.timeout);
  try {
    if (message.status !== "completed" || !message.output?.metadata) throw new Error(message.error?.code || "VIDEO_AUDIO_FAILED");
    entry.committing = true;
    const meta = message.output.metadata;
    let stored, updated;
    if (op.audio_action === "extract") {
      op.result_audio_path = entry.output;
      op.audio_output = { container: "m4a", audioCodec: "aac", duration: meta.duration, sampleRate: meta.sampleRate, channels: meta.channels };
    } else {
      const form = new (require("form-data"))(); form.append("video", fs.createReadStream(entry.output), { filename: `${path.parse(entry.source.name).name}-${op.audio_action}.mp4`, contentType: "video/mp4" });
      stored = await post_video(op.user_id, op.project_id, form);
      const current = await Project.getOne(op.user_id, op.project_id);
      updated = await Project.appendVideoIfVersion(op.user_id, op.project_id, { user_id: op.user_id, project_id: op.project_id, sourceVideoId: entry.source._id, stage: "video-src", object_key: stored.data.data.imageKey, name: `${path.parse(entry.source.name).name}-${op.audio_action}.mp4`, ...meta, sha256: meta.sha256 }, current.version);
      if (!updated) { await delete_video(op.user_id, op.project_id, stored.data.data.imageKey); throw new Error("VIDEO_AUDIO_FAILED"); }
      op.result_video_id = updated.videos.at(-1)._id;
    }
    op.status = "completed"; op.progress = 100; op.finished_at = new Date(); await op.save(); publish(op);
    if (op.audio_action === "extract") {
      const downloadCleanupDelay = Number(process.env.VIDEO_AUDIO_DOWNLOAD_TIMEOUT_MS || process.env.VIDEO_AUDIO_TIMEOUT_MS || 30 * 60 * 1000);
      const timer = setTimeout(async () => {
        const stale = await VideoOperation.findById(op._id).select("+result_audio_path").exec();
        if (stale?.result_audio_path === entry.output) {
          stale.result_audio_path = null;
          await stale.save().catch(() => {});
          await cleanup(entry.dir);
        }
      }, downloadCleanupDelay);
      timer.unref?.();
    }
  } catch (error) { await require("./videoOperationService").failAudioOperation(op, error); }
  finally {
    pending.delete(id);
    if (op.audio_action !== "extract" || op.status !== "completed") await cleanup(entry.dir);
  }
  return true;
}

function cancelAudio(operationId) { const entry = pending.get(String(operationId)); if (!entry) return false; if (entry.committing) return "committing"; clearTimeout(entry.timeout); pending.delete(String(operationId)); cleanup(entry.dir).catch(() => {}); return true; }
module.exports = { dispatchAudio, handleToolResponse, cancelAudio };
