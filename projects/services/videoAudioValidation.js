const { execFile } = require("child_process");
const { promisify } = require("util");
const run = promisify(execFile);

async function probeAudio(filePath) {
  try {
    const { stdout } = await run("ffprobe", ["-v", "error", "-show_streams", "-show_format", "-of", "json", filePath]);
    const probe = JSON.parse(stdout);
    const stream = (probe.streams || []).find((item) => item.codec_type === "audio");
    if (!stream) throw new Error("VIDEO_AUDIO_NO_TRACK");
    return { codec: String(stream.codec_name || "").toLowerCase(), duration: Number(stream.duration || probe.format?.duration || 0), sampleRate: Number(stream.sample_rate || 0) || null, channels: Number(stream.channels || 0) || null, container: String(probe.format?.format_name || "").toLowerCase() };
  } catch (error) {
    if (error.message?.startsWith("VIDEO_AUDIO_")) throw error;
    throw new Error("VIDEO_AUDIO_INVALID");
  }
}

async function validateReplacement(file, startSeconds, endSeconds) {
  if (!file?.path) throw new Error("VIDEO_AUDIO_INVALID");
  const ext = String(file.originalname || "").split(".").pop().toLowerCase();
  const mime = String(file.mimetype || "").toLowerCase();
  if (!["mp3", "m4a"].includes(ext)) throw new Error("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
  const metadata = await probeAudio(file.path);
  if ((ext === "mp3" && metadata.codec !== "mp3") || (ext === "m4a" && metadata.codec !== "aac")) throw new Error("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
  const start = startSeconds == null || startSeconds === "" ? 0 : Number(startSeconds);
  const end = endSeconds == null || endSeconds === "" ? null : Number(endSeconds);
  if (!Number.isFinite(start) || start < 0 || (end !== null && (!Number.isFinite(end) || end <= start || end > metadata.duration))) throw new Error("VIDEO_AUDIO_INVALID");
  return { ...metadata, startSeconds: start, endSeconds: end };
}
module.exports = { probeAudio, validateReplacement };
