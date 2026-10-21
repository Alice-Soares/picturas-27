function shouldReserveVideoQuota({ type }) {
  // Only frame tools invoke AI. FFmpeg operations (trim, conversion, audio,
  // frame extraction and merge) are available without a daily quota.
  return type === "frame_tool";
}

module.exports = { shouldReserveVideoQuota };
