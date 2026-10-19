function validateTrimInterval({ startSeconds, endSeconds, duration }) {
  if (![startSeconds, endSeconds, duration].every(Number.isFinite)) {
    throw new Error("VIDEO_TRIM_INVALID_INTERVAL");
  }
  if (startSeconds < 0 || startSeconds > duration) {
    throw new Error("VIDEO_TRIM_INVALID_START");
  }
  if (endSeconds < 0 || endSeconds > duration) {
    throw new Error("VIDEO_TRIM_INVALID_END");
  }
  if (startSeconds >= endSeconds) {
    throw new Error("VIDEO_TRIM_INVALID_INTERVAL");
  }
  if (endSeconds - startSeconds < 1) {
    throw new Error("VIDEO_TRIM_TOO_SHORT");
  }
  return {
    startSeconds,
    endSeconds,
    durationSeconds: endSeconds - startSeconds,
  };
}

module.exports = { validateTrimInterval };
