const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFile } = require("child_process");
const { promisify } = require("util");
const ffmpegPath = require("ffmpeg-static");
const ffprobePath = require("ffprobe-static").path;
process.env.FFMPEG_PATH = ffmpegPath;
const { extractFrames, assembleVideo } = require("../services/videoFramePipeline");

const execFileAsync = promisify(execFile);

describe("video frame tool media integration", () => {
  test("recomposes frames with the original resolution and audio stream", async () => {
    const directory = await fs.promises.mkdtemp(path.join(os.tmpdir(), "picturas-frame-integration-"));
    const input = path.join(directory, "input.mp4");
    const frames = path.join(directory, "frames");
    const processed = path.join(directory, "processed");
    const output = path.join(directory, "output.mp4");
    try {
      await fs.promises.mkdir(frames);
      await fs.promises.mkdir(processed);
      await execFileAsync(ffmpegPath, [
        "-y", "-f", "lavfi", "-i", "testsrc=size=160x90:rate=10",
        "-f", "lavfi", "-i", "sine=frequency=1000:sample_rate=44100",
        "-t", "2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-c:a", "aac", input,
      ]);
      const extracted = await extractFrames(input, frames, 0, 1.5, 5);
      assert.ok(extracted.length > 0);
      await Promise.all(extracted.map((frame, index) => fs.promises.copyFile(
        frame,
        path.join(processed, `processed-${String(index + 1).padStart(8, "0")}.png`),
      )));
      await assembleVideo(input, processed, output, 0, 1.5, 5);
      const { stdout } = await execFileAsync(ffprobePath, [
        "-v", "error", "-show_streams", "-of", "json", output,
      ]);
      const streams = JSON.parse(stdout).streams;
      const video = streams.find((stream) => stream.codec_type === "video");
      const audio = streams.find((stream) => stream.codec_type === "audio");
      assert.strictEqual(video.width, 160);
      assert.strictEqual(video.height, 90);
      assert.ok(audio);
    } finally {
      await fs.promises.rm(directory, { recursive: true, force: true });
    }
  });
});
