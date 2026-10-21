const { validateReplacement } = require("../services/videoAudioValidation");

test("TST-AUD-003 replacement rejects unsupported extension before probing", async () => {
  await expectAsync(validateReplacement({ path: "/missing", originalname: "audio.wav", mimetype: "audio/wav" })).rejects("VIDEO_AUDIO_FORMAT_UNSUPPORTED");
});

test("TST-AUD-004 replacement requires a staged file", async () => {
  await expectAsync(validateReplacement(null)).rejects("VIDEO_AUDIO_INVALID");
});
