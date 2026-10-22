const { execFile } = require("child_process");
const { promisify } = require("util");
const run = promisify(execFile);

async function probeAudio(filePath) {
  try {
    const { stdout } = await run("ffprobe", ["-v", "error", "-show_streams", "-show_format", "-of", "json", filePath]);
    const probe = JSON.parse(stdout);
    const streams = probe.streams || [];
    const stream = streams.find((item) => item.codec_type === "audio");
    if (!stream) throw new Error("VIDEO_AUDIO_NO_TRACK");
    return { codec: String(stream.codec_name || "").toLowerCase(), hasVideo: streams.some((item) => item.codec_type === "video" && !item.disposition?.attached_pic), duration: Number(stream.duration || probe.format?.duration || 0), sampleRate: Number(stream.sample_rate || 0) || null, channels: Number(stream.channels || 0) || null, container: String(probe.format?.format_name || "").toLowerCase() };
  } catch (error) {
    if (error.message?.startsWith("VIDEO_AUDIO_")) throw error;
    throw new Error("VIDEO_AUDIO_INVALID");
  }
}

async function validateReplacement(file, startSeconds, endSeconds, inspectAudio = probeAudio) {
  if (!file?.path) throw new Error("VIDEO_AUDIO_INVALID");
  let metadata;
  try {
    metadata = await inspectAudio(file.path);
  } catch (error) {
    if (error.message === "VIDEO_AUDIO_NO_TRACK") throw error;
    throw new Error("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
  }
  if (!metadata.hasVideo) {
    const ext = String(file.originalname || "").split(".").pop().toLowerCase();
    const supportedAudioFile = (ext === "mp3" && metadata.codec === "mp3") ||
      (ext === "m4a" && metadata.codec === "aac");
    if (!supportedAudioFile) throw new Error("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
  }
  const start = startSeconds == null || startSeconds === "" ? 0 : Number(startSeconds);
  const end = endSeconds == null || endSeconds === "" ? null : Number(endSeconds);
  if (!Number.isFinite(start) || start < 0 || start >= metadata.duration ||
      (end !== null && (!Number.isFinite(end) || end <= start || end > metadata.duration))) {
    throw new Error("VIDEO_AUDIO_INVALID");
  }
  return { ...metadata, startSeconds: start, endSeconds: end };
}
module.exports = { probeAudio, validateReplacement };
