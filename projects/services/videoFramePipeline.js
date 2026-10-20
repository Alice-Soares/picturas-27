const fs = require("fs");
const { spawn } = require("child_process");

function runFfmpeg(args) {
  return new Promise((resolve, reject) => {
    const child = spawn("ffmpeg", ["-y", ...args], { stdio: ["ignore", "ignore", "pipe"] });
    let stderr = "";
    child.stderr.on("data", (chunk) => { stderr += chunk.toString(); });
    child.on("error", reject);
    child.on("close", (code) => code === 0 ? resolve() : reject(new Error(`FFMPEG_FAILED:${stderr.slice(-200)}`)));
  });
}

async function extractFrames(input, directory, startSeconds, endSeconds, outputFps) {
  const pattern = `${directory}/frame-%08d.png`;
  await runFfmpeg([
    "-ss", String(startSeconds), "-to", String(endSeconds), "-i", input,
    "-vf", `fps=${outputFps}`, "-vsync", "0", pattern,
  ]);
  return (await fs.promises.readdir(directory))
    .filter((name) => /^frame-\d+\.png$/.test(name))
    .sort()
    .map((name) => `${directory}/${name}`);
}

async function assembleVideo(input, framesDirectory, output, startSeconds, endSeconds, outputFps) {
  const pattern = `${framesDirectory}/processed-%08d.png`;
  await runFfmpeg([
    "-framerate", String(outputFps), "-i", pattern,
    "-ss", String(startSeconds), "-t", String(endSeconds - startSeconds),
    "-i", input, "-map", "0:v:0", "-map", "1:a?", "-c:v", "libx264",
    "-pix_fmt", "yuv420p", "-c:a", "copy", "-shortest", output,
  ]);
  return output;
}

module.exports = { extractFrames, assembleVideo };