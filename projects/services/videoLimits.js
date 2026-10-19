const DECIMAL_MB = 1_000_000;
const DECIMAL_GB = 1_000_000_000;

const limits = {
  registered: {
    maxBytes: 100 * DECIMAL_MB,
    maxDuration: 5 * 60,
    maxWidth: 1920,
    maxHeight: 1080,
    maxFps: 60,
  },
  premium: {
    maxBytes: DECIMAL_GB,
    maxDuration: 30 * 60,
    maxWidth: 3840,
    maxHeight: 2160,
    maxFps: 60,
  },
};

function getVideoLimits(profile) {
  const key = profile === "premium" ? "premium" : "registered";
  return limits[key];
}

function validateVideoLimits(metadata, profile) {
  const max = getVideoLimits(profile);
  const failures = [];
  if (metadata.size > max.maxBytes) failures.push("size");
  if (metadata.duration > max.maxDuration) failures.push("duration");
  if (metadata.width > max.maxWidth || metadata.height > max.maxHeight) failures.push("resolution");
  if (metadata.fps > max.maxFps) failures.push("fps");
  return failures;
}

module.exports = { DECIMAL_MB, DECIMAL_GB, getVideoLimits, validateVideoLimits };
