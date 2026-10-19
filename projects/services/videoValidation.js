const { validateVideoLimits } = require("./videoLimits");

function validateVideo(metadata, profile) {
  const failures = [];
  if (!metadata.container.split(",").includes("mp4")) failures.push("container");
  if (metadata.videoCodec !== "h264") failures.push("videoCodec");
  if (metadata.audioCodec && metadata.audioCodec !== "aac") failures.push("audioCodec");
  failures.push(...validateVideoLimits(metadata, profile));
  if (failures.length) {
    const error = new Error("VIDEO_VALIDATION_FAILED");
    error.failures = [...new Set(failures)];
    throw error;
  }
  return metadata;
}

module.exports = { validateVideo };
