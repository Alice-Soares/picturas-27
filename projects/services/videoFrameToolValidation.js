const supportedTools = new Set([
  "border", "brightness", "contrast", "cut", "saturation",
  "binarization", "rotate", "resize", "watermark",
]);

function validationError(code) {
  const error = new Error(code);
  error.status = 400;
  return error;
}

function validateTools(tools) {
  if (!Array.isArray(tools) || tools.length === 0) {
    throw validationError("VIDEO_FRAME_TOOL_REQUIRED");
  }
  const positions = new Set();
  return tools
    .map((tool, index) => {
      if (!tool || !supportedTools.has(tool.procedure)) {
        throw validationError("VIDEO_FRAME_TOOL_INCOMPATIBLE");
      }
      const position = Number.isInteger(tool.position) ? tool.position : index;
      if (position < 0 || positions.has(position)) {
        throw validationError("VIDEO_FRAME_TOOL_INVALID_ORDER");
      }
      if (!tool.params || typeof tool.params !== "object" || Array.isArray(tool.params)) {
        throw validationError("VIDEO_FRAME_TOOL_INVALID_PARAMS");
      }
      positions.add(position);
      return { position, procedure: tool.procedure, params: tool.params };
    })
    .sort((left, right) => left.position - right.position);
}

function validateFrameInterval({ startSeconds, endSeconds, outputFps, duration, sourceFps }) {
  const start = Number(startSeconds ?? 0);
  const end = Number(endSeconds ?? duration);
  const fps = Number(outputFps ?? sourceFps);
  if (!Number.isFinite(start) || !Number.isFinite(end) || start < 0 || end <= start || end > duration) {
    throw validationError("VIDEO_FRAME_TOOL_INVALID_INTERVAL");
  }
  if (!Number.isFinite(fps) || fps <= 0) {
    throw validationError("VIDEO_FRAME_TOOL_INVALID_FPS");
  }
  return { startSeconds: start, endSeconds: end, outputFps: fps };
}

module.exports = { supportedTools, validateTools, validateFrameInterval };
