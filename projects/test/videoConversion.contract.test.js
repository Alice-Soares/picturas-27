const assert = require("assert");
const VideoOperation = require("../models/videoOperation");
const {
  conversionOptionsResponse,
  validateConversionOptions,
  estimateOutputSize,
} = require("../services/videoConversionValidation");
const { publicConversionError } = require("../services/videoConversionErrors");
const { conversionRequest, isConversionMessage } = require("../utils/videoConversionMsg");

describe("video conversion contract", () => {
  test("advertises source metadata, supported output matrix and profile limits", () => {
    const response = conversionOptionsResponse({
      _id: "video-1", name: "source.mp4", container: "mp4", videoCodec: "h264",
      audioCodec: "aac", duration: 12.5, width: 1280, height: 720, fps: 30,
    }, "registered");

    assert.deepStrictEqual(response.source, {
      id: "video-1", name: "source.mp4", container: "mp4", videoCodec: "h264",
      audioCodec: "aac", duration: 12.5, width: 1280, height: 720, fps: 30, size: null,
    });
    assert.deepStrictEqual(response.containers, [{
      name: "mp4", videoCodecs: ["h264"], audioCodecs: ["aac"],
    }]);
    assert.deepStrictEqual(response.resolutionLimits, { width: 1920, height: 1080 });
  });

  test("advertises the premium resolution limit", () => {
    assert.deepStrictEqual(
      conversionOptionsResponse({ _id: "video-1" }, "premium").resolutionLimits,
      { width: 3840, height: 2160 },
    );
  });

  test("accepts conversion without audio and normalizes option casing", () => {
    assert.deepStrictEqual(validateConversionOptions({
      outputContainer: "MP4", outputVideoCodec: "H264", outputWidth: "1920", outputHeight: "1080",
    }, "registered"), {
      outputContainer: "mp4", outputVideoCodec: "h264", outputAudioCodec: null,
      outputWidth: 1920, outputHeight: 1080,
    });
  });

  test("rejects output dimensions above either profile boundary", () => {
    for (const options of [
      { outputContainer: "mp4", outputVideoCodec: "h264", outputAudioCodec: "aac", outputWidth: 1921, outputHeight: 720 },
      { outputContainer: "mp4", outputVideoCodec: "h264", outputAudioCodec: "aac", outputWidth: 1280, outputHeight: 1081 },
    ]) {
      assert.throws(() => validateConversionOptions(options, "registered"), /VIDEO_CONVERSION_INVALID_OPTIONS/);
    }
    assert.doesNotThrow(() => validateConversionOptions({
      outputContainer: "mp4", outputVideoCodec: "h264", outputAudioCodec: "aac",
      outputWidth: 3840, outputHeight: 2160,
    }, "premium"));
  });

  test("estimates size from bitrate and duration when both are available", () => {
    assert.strictEqual(estimateOutputSize({ duration: 12, width: 1280, height: 720, bitrate: 800000 }), 1200000);
  });

  test("defines conversion output fields on the operation model", () => {
    const schema = VideoOperation.schema;
    assert.ok(schema.path("type").enumValues.includes("conversion"));
    for (const field of [
      "output.outputContainer", "output.outputVideoCodec", "output.outputAudioCodec",
      "output.outputWidth", "output.outputHeight", "output.estimatedSize",
    ]) assert.ok(schema.path(field), `missing schema path ${field}`);
  });

  test("builds a correlated RabbitMQ request with the configured output", () => {
    const message = conversionRequest({
      operation: {
        _id: "operation-1",
        end_seconds: 12.5,
        output: {
          outputContainer: "mp4", outputVideoCodec: "h264", outputAudioCodec: "aac",
          outputWidth: 1280, outputHeight: 720,
        },
      },
      inputVideoURI: "/app/images/input.mp4",
      outputVideoURI: "/app/images/output.mp4",
    });

    assert.strictEqual(isConversionMessage(message), true);
    assert.strictEqual(message.correlationId, "operation-1");
    assert.deepStrictEqual(message.parameters, {
      inputVideoURI: "/app/images/input.mp4", outputVideoURI: "/app/images/output.mp4",
      outputContainer: "mp4", outputVideoCodec: "h264", outputAudioCodec: "aac",
      outputWidth: 1280, outputHeight: 720, duration: 12.5,
    });
  });

  test("maps internal failures to stable public conversion errors", () => {
    assert.deepStrictEqual(publicConversionError(new Error("VIDEO_CONVERSION_INVALID_OPTIONS")), {
      code: "VIDEO_CONVERSION_INVALID_OPTIONS", message: "VIDEO_CONVERSION_INVALID_OPTIONS",
    });
    assert.deepStrictEqual(publicConversionError(new Error("ffmpeg path /secret failed")), {
      code: "VIDEO_CONVERSION_FAILED", message: "VIDEO_CONVERSION_FAILED",
    });
  });
});
