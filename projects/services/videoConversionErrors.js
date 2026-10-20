const PUBLIC_ERRORS = new Set([
  "VIDEO_CONVERSION_INVALID_OPTIONS",
  "VIDEO_CONVERSION_UNAUTHORIZED",
  "VIDEO_CONVERSION_NOT_FOUND",
  "VIDEO_CONVERSION_QUOTA_EXCEEDED",
  "VIDEO_CONVERSION_CANCELLED",
  "VIDEO_CONVERSION_FAILED",
]);

function publicConversionError(error) {
  const code = PUBLIC_ERRORS.has(error?.message) ? error.message : "VIDEO_CONVERSION_FAILED";
  return { code, message: code };
}

module.exports = { publicConversionError };
