const { validateReplacement } = require("../services/videoAudioValidation");

test("TST-AUD-003 replacement rejects unsupported audio-only formats", async () => {
  await expectAsync(validateReplacement(
    { path: "/tmp/audio.wav", originalname: "audio.wav", mimetype: "audio/wav" },
    undefined,
    undefined,
    async () => ({ codec: "pcm_s16le", hasVideo: false, duration: 4 }),
  )).rejects("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
});

test("TST-AUD-017 replacement accepts a video file by its detected audio stream", async () => {
  const metadata = await validateReplacement(
    { path: "/tmp/replacement.mp4", originalname: "replacement.mp4", mimetype: "video/mp4" },
    undefined,
    undefined,
    async () => ({ codec: "opus", hasVideo: true, duration: 4, sampleRate: 48000, channels: 2, container: "matroska,webm" }),
  );
  expect(metadata.codec).toBe("opus");
  expect(metadata.startSeconds).toBe(0);
  expect(metadata.endSeconds).toBe(null);
});

test("TST-AUD-018 replacement continues to accept MP3 and M4A/AAC audio-only files", async () => {
  for (const [name, codec] of [["replacement.mp3", "mp3"], ["replacement.m4a", "aac"]]) {
    const metadata = await validateReplacement(
      { path: "/tmp/" + name, originalname: name },
      undefined,
      undefined,
      async () => ({ codec, hasVideo: false, duration: 4 }),
    );
    expect(metadata.codec).toBe(codec);
  }
});

test("TST-AUD-019 replacement keeps unsupported audio-only formats rejected", async () => {
  await expectAsync(validateReplacement(
    { path: "/tmp/replacement.wav", originalname: "replacement.wav" },
    undefined,
    undefined,
    async () => ({ codec: "pcm_s16le", hasVideo: false, duration: 4 }),
  )).rejects("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
});

test("TST-AUD-020 replacement rejects a video without an audio stream", async () => {
  await expectAsync(validateReplacement(
    { path: "/tmp/silent.mp4", originalname: "silent.mp4", mimetype: "video/mp4" },
    undefined,
    undefined,
    async () => { throw new Error("VIDEO_AUDIO_NO_TRACK"); },
  )).rejects("VIDEO_AUDIO_NO_TRACK");
});

test("TST-AUD-021 replacement rejects corrupt media with a safe unsupported-format error", async () => {
  await expectAsync(validateReplacement(
    { path: "/tmp/broken.mp4", originalname: "broken.mp4", mimetype: "video/mp4" },
    undefined,
    undefined,
    async () => { throw new Error("VIDEO_AUDIO_INVALID"); },
  )).rejects("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
});

test("TST-AUD-004 replacement requires a staged file", async () => {
  await expectAsync(validateReplacement(null)).rejects("VIDEO_AUDIO_INVALID");
});
