const messages = {
  VIDEO_TRIM_QUOTA_EXCEEDED: "The processing quota is exhausted",
  VIDEO_FRAME_TOOL_REQUIRED: "At least one compatible image tool is required",
  VIDEO_FRAME_TOOL_INCOMPATIBLE: "The selected tool cannot produce video frames",
  VIDEO_FRAME_TOOL_INVALID_ORDER: "The tool order is invalid",
  VIDEO_FRAME_TOOL_INVALID_PARAMS: "The tool parameters are invalid",
  VIDEO_FRAME_TOOL_INVALID_INTERVAL: "The video interval is invalid",
  VIDEO_FRAME_TOOL_INVALID_FPS: "The output frame rate is invalid",
  VIDEO_FRAME_TOOL_NOT_FOUND: "The video operation was not found",
  VIDEO_FRAME_TOOL_UNAUTHORIZED: "The video operation is not authorized",
  VIDEO_FRAME_TOOL_QUOTA_EXCEEDED: "The processing quota is exhausted",
  VIDEO_FRAME_TOOL_CANCELLED: "The video operation was cancelled",
  VIDEO_FRAME_TOOL_FAILED: "The video operation failed",
};

function publicFrameToolError(error) {
  const code = messages[error?.message] ? error.message : "VIDEO_FRAME_TOOL_FAILED";
  return { code, message: messages[code] };
}

module.exports = { publicFrameToolError };