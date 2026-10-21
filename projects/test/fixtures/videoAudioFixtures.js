module.exports = {
  remove: { action: "remove", audioCodec: "aac" },
  replaceMp3: { action: "replace", name: "replacement.mp3", codec: "mp3" },
  replaceM4a: { action: "replace", name: "replacement.m4a", codec: "aac" },
  extract: { action: "extract", outputContainer: "m4a", outputCodec: "aac" },
  noAudio: { audioCodec: null },
  unsupported: { name: "replacement.wav", codec: "pcm_s16le" },
};
