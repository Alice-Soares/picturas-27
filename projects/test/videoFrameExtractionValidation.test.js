const { validateExtraction, estimateFrames } = require("../services/videoFrameExtractionValidation");

describe("video frame extraction validation", () => {
  test("calculates the effective estimate using the requested maximum", () => {
    const result = validateExtraction({
      startSeconds: 0,
      endSeconds: 2,
      duration: 10,
      sourceFps: 25,
      maxFrames: 10,
      profile: "registered",
    });
    expect(result.estimatedFrames).toBe(10);
    expect(estimateFrames({ startSeconds: 0, endSeconds: 2, sourceFps: 25 })).toBe(50);
  });

  test("accepts the registered and premium limits", () => {
    expect(validateExtraction({ startSeconds: 0, endSeconds: 1, duration: 2, sourceFps: 1000, maxFrames: 1000, profile: "registered" }).maxFrames).toBe(1000);
    expect(validateExtraction({ startSeconds: 0, endSeconds: 1, duration: 2, sourceFps: 5000, maxFrames: 5000, profile: "premium" }).maxFrames).toBe(5000);
  });

  test("rejects invalid interval, format and limits", () => {
    expect(() => validateExtraction({ startSeconds: 2, endSeconds: 1, duration: 3, sourceFps: 25, maxFrames: 10, profile: "premium" })).toThrow("INVALID_INTERVAL");
    expect(() => validateExtraction({ startSeconds: 0, endSeconds: 1, duration: 3, sourceFps: 25, maxFrames: 10, profile: "premium", outputFormat: "png" })).toThrow("FORMAT_UNSUPPORTED");
    expect(() => validateExtraction({ startSeconds: 0, endSeconds: 1, duration: 3, sourceFps: 25, maxFrames: 1001, profile: "registered" })).toThrow("LIMIT_EXCEEDED");
  });
});