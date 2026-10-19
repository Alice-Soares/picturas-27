const PUBLIC_ERRORS = new Set([
  "VIDEO_TRIM_INVALID_INTERVAL",
  "VIDEO_TRIM_INVALID_START",
  "VIDEO_TRIM_INVALID_END",
  "VIDEO_TRIM_TOO_SHORT",
  "VIDEO_TRIM_NOT_FOUND",
  "VIDEO_TRIM_UNAUTHORIZED",
  "VIDEO_TRIM_QUOTA_EXCEEDED",
  "VIDEO_TRIM_CANCELLED",
  "VIDEO_TRIM_FAILED",
]);

function publicTrimError(error) {
  const code = PUBLIC_ERRORS.has(error?.message)
    ? error.message
    : "VIDEO_TRIM_FAILED";
  return { code, message: code === "VIDEO_TRIM_FAILED" ? "Não foi possível recortar o vídeo." : code };
}

module.exports = { publicTrimError };
