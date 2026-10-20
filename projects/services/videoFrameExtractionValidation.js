const LIMITS = Object.freeze({
  registered: 1000,
  premium: 5000,
});

function validationError(code) {
  const error = new Error(code);
  error.status = 400;
  return error;
}

function estimateFrames({ startSeconds, endSeconds, sourceFps }) {
  const start = Number(startSeconds);
  const end = Number(endSeconds);
  const fps = Number(sourceFps);
  if (!Number.isFinite(start) || !Number.isFinite(end) || !Number.isFinite(fps) || fps <= 0) {
    throw validationError("VIDEO_FRAME_EXTRACT_INVALID_PARAMETERS");
  }
  const estimated = Math.ceil((end - start) * fps);
  if (estimated <= 0) throw validationError("VIDEO_FRAME_EXTRACT_NO_FRAMES");
  return estimated;
}

function validateExtraction({
  startSeconds,
  endSeconds,
  duration,
  sourceFps,
  maxFrames,
  profile,
  outputFormat = "jpeg",
}) {
  const videoDuration = Number(duration);
  const start = Number(startSeconds ?? 0);
  const end = Number(endSeconds ?? videoDuration);
  const requested = Number(maxFrames);
  const limit = LIMITS[profile] || LIMITS.registered;

  if (!Number.isFinite(videoDuration) || videoDuration <= 0) {
    throw validationError("VIDEO_FRAME_EXTRACT_INVALID_VIDEO");
  }
  if (!Number.isFinite(start) || !Number.isFinite(end) || start < 0 || end <= start || end > videoDuration) {
    throw validationError("VIDEO_FRAME_EXTRACT_INVALID_INTERVAL");
  }
  if (!Number.isInteger(requested) || requested <= 0) {
    throw validationError("VIDEO_FRAME_EXTRACT_INVALID_MAX_FRAMES");
  }
  if (requested > limit) throw validationError("VIDEO_FRAME_EXTRACT_LIMIT_EXCEEDED");
  if (outputFormat.toLowerCase() !== "jpeg") {
    throw validationError("VIDEO_FRAME_EXTRACT_FORMAT_UNSUPPORTED");
  }

  const totalEstimatedFrames = estimateFrames({ startSeconds: start, endSeconds: end, sourceFps });
  const estimatedFrames = Math.min(totalEstimatedFrames, requested);
  if (estimatedFrames > limit) {
    throw validationError("VIDEO_FRAME_EXTRACT_LIMIT_EXCEEDED");
  }

  return {
    startSeconds: start,
    endSeconds: end,
    maxFrames: requested,
    estimatedFrames,
    outputFormat: "jpeg",
  };
}

module.exports = { LIMITS, estimateFrames, validateExtraction };