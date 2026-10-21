const messages = {
  VIDEO_AUDIO_UNAUTHORIZED: [403, "VIDEO_AUDIO_UNAUTHORIZED"],
  VIDEO_AUDIO_NOT_FOUND: [404, "VIDEO_AUDIO_NOT_FOUND"],
  VIDEO_AUDIO_NO_TRACK: [422, "VIDEO_AUDIO_NO_TRACK"],
  VIDEO_AUDIO_FORMAT_UNSUPPORTED: [415, "VIDEO_AUDIO_FORMAT_UNSUPPORTED"],
  VIDEO_AUDIO_INVALID: [400, "VIDEO_AUDIO_INVALID"],
  VIDEO_AUDIO_QUOTA_EXCEEDED: [429, "VIDEO_AUDIO_QUOTA_EXCEEDED"],
  VIDEO_AUDIO_FAILED: [500, "VIDEO_AUDIO_FAILED"],
};
function publicAudioError(error) {
  const code = String(error?.code || error?.message || "").split(":", 1)[0];
  const [status, safe] = messages[code] || [500, "VIDEO_AUDIO_FAILED"];
  return { status: error?.status || status, code: safe };
}
module.exports = { publicAudioError };
