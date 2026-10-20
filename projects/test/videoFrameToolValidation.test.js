const assert = require("assert");
const { validateTools, validateFrameInterval } = require("../services/videoFrameToolValidation");

describe("video frame tool validation", () => {
  test("normalizes tools by position", () => {
    const tools = validateTools([
      { position: 1, procedure: "contrast", params: { contrastFactor: 1.1 } },
      { position: 0, procedure: "brightness", params: { brightness: 1.1 } },
    ]);
    expect(tools.map((tool) => tool.procedure)).toEqual(["brightness", "contrast"]);
  });

  test("rejects metadata and unknown tools", () => {
    expect(() => validateTools([{ procedure: "people_ai", params: {} }])).toThrow("VIDEO_FRAME_TOOL_INCOMPATIBLE");
    expect(() => validateTools([{ procedure: "unknown", params: {} }])).toThrow("VIDEO_FRAME_TOOL_INCOMPATIBLE");
  });

  test("validates interval and output fps", () => {
    assert.deepStrictEqual(
      validateFrameInterval({ startSeconds: 1, endSeconds: 5, outputFps: 25, duration: 10, sourceFps: 30 }),
      { startSeconds: 1, endSeconds: 5, outputFps: 25 },
    );
    expect(() => validateFrameInterval({ startSeconds: 5, endSeconds: 1, outputFps: 25, duration: 10, sourceFps: 30 }))
      .toThrow("VIDEO_FRAME_TOOL_INVALID_INTERVAL");
    expect(() => validateFrameInterval({ startSeconds: 0, endSeconds: 5, outputFps: 0, duration: 10, sourceFps: 30 }))
      .toThrow("VIDEO_FRAME_TOOL_INVALID_FPS");
  });
});