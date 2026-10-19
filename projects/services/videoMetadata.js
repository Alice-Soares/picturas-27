const fs = require("fs");
const crypto = require("crypto");
const { execFile } = require("child_process");
const { promisify } = require("util");

const execFileAsync = promisify(execFile);

async function readVideoMetadata(file) {
  if (!file?.path) throw new Error("VIDEO_FILE_REQUIRED");
  try {
    const { stdout } = await execFileAsync("ffprobe", [
      "-v", "error", "-show_streams", "-show_format", "-of", "json", file.path,
    ]);
    const probe = JSON.parse(stdout);
    const streams = probe.streams || [];
    const video = streams.find((stream) => stream.codec_type === "video");
    const audio = streams.find((stream) => stream.codec_type === "audio");
    if (!video) throw new Error("VIDEO_STREAM_REQUIRED");

    const fps = video.r_frame_rate && video.r_frame_rate.includes("/")
      ? Number(video.r_frame_rate.split("/")[0]) / Number(video.r_frame_rate.split("/")[1])
      : Number(video.r_frame_rate || 0);
    const stat = await fs.promises.stat(file.path);
    const hash = await new Promise((resolve, reject) => {
      const digest = crypto.createHash("sha256");
      const stream = fs.createReadStream(file.path);
      stream.on("data", (chunk) => digest.update(chunk));
      stream.on("error", reject);
      stream.on("end", () => resolve(digest.digest("hex")));
    });

    return {
      container: String(probe.format?.format_name || "").toLowerCase(),
      videoCodec: String(video.codec_name || "").toLowerCase(),
      audioCodec: audio ? String(audio.codec_name || "").toLowerCase() : null,
      size: stat.size,
      duration: Number(probe.format?.duration || 0),
      width: Number(video.width || 0),
      height: Number(video.height || 0),
      fps,
      sha256: hash,
    };
  } catch (error) {
    if (error.code === "ENOENT") throw new Error("VIDEO_ANALYZER_UNAVAILABLE");
    if (error.message.startsWith("VIDEO_")) throw error;
    throw new Error("VIDEO_METADATA_INVALID");
  }
}

module.exports = { readVideoMetadata };
