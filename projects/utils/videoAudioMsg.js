const { v4: uuidv4 } = require("uuid");
function audioRequest({ operation, inputVideoURI, replacementAudioURI, outputURI }) {
  return { messageId: `video-audio-${operation._id}-${uuidv4()}`, correlationId: String(operation._id), timestamp: new Date().toISOString(), procedure: "video_audio", parameters: { action: operation.audio_action, inputVideoURI, replacementAudioURI: replacementAudioURI || null, outputURI, audioStartSeconds: operation.audio_start_seconds, audioEndSeconds: operation.audio_end_seconds } };
}
function isAudioMessage(message) { return message?.procedure === "video_audio" && Boolean(message.correlationId); }
module.exports = { audioRequest, isAudioMessage };
