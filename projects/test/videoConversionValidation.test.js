const assert = require("assert");
const {
  validateConversionOptions,
  maxResolution,
  estimateOutputSize,
} = require("../services/videoConversionValidation");

describe("video conversion validation", () => {
  test("accepts the MVP MP4/H264/AAC matrix", () => {
    assert.deepStrictEqual(validateConversionOptions({
      outputContainer: "mp4",
      outputVideoCodec: "h264",
      outputAudioCodec: "aac",
      outputWidth: 1280,
      outputHeight: 720,
    }, "registered").outputWidth, 1280);
  });

  test("enforces profile resolution limits", () => {
    assert.deepStrictEqual(maxResolution("registered"), { width: 1920, height: 1080 });
    assert.deepStrictEqual(maxResolution("premium"), { width: 3840, height: 2160 });
    assert.throws(() => validateConversionOptions({
      outputContainer: "mp4", outputVideoCodec: "h264", outputAudioCodec: "aac",
      outputWidth: 3840, outputHeight: 2160,
    }, "registered"), /VIDEO_CONVERSION_INVALID_OPTIONS/);
  });

  test("keeps estimates nullable when bitrate metadata is unavailable", () => {
    assert.strictEqual(estimateOutputSize({ duration: 10, width: 1280, height: 720 }), null);
  });
});
