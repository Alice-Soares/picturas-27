const supportedConversion = {
  mp4: {
    videoCodecs: ["h264"],
    audioCodecs: ["aac", null],
  },
};

function maxResolution(profile) {
  return profile === "premium"
    ? { width: 3840, height: 2160 }
    : { width: 1920, height: 1080 };
}

function validateConversionOptions(options = {}, profile = "registered") {
  const outputContainer = String(options.outputContainer || "").toLowerCase();
  const outputVideoCodec = String(options.outputVideoCodec || "").toLowerCase();
  const outputAudioCodec = options.outputAudioCodec == null
    ? null
    : String(options.outputAudioCodec).toLowerCase();
  const outputWidth = Number(options.outputWidth);
  const outputHeight = Number(options.outputHeight);
  const limit = maxResolution(profile);
  const matrix = supportedConversion[outputContainer];

  if (!matrix || !matrix.videoCodecs.includes(outputVideoCodec) ||
      !matrix.audioCodecs.includes(outputAudioCodec) ||
      !Number.isInteger(outputWidth) || !Number.isInteger(outputHeight) ||
      outputWidth <= 0 || outputHeight <= 0 ||
      outputWidth > limit.width || outputHeight > limit.height) {
    const error = new Error("VIDEO_CONVERSION_INVALID_OPTIONS");
    error.status = 400;
    throw error;
  }

  return { outputContainer, outputVideoCodec, outputAudioCodec, outputWidth, outputHeight };
}

function estimateOutputSize({ duration, width, height, bitrate }) {
  if (!Number.isFinite(duration) || duration <= 0 || !Number.isFinite(bitrate) || bitrate <= 0) {
    return null;
  }
  if (!Number.isFinite(width) || !Number.isFinite(height)) return null;
  return Math.round((bitrate * duration) / 8);
}

module.exports = { supportedConversion, maxResolution, validateConversionOptions, estimateOutputSize };
