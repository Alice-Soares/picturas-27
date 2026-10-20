const { validateTools } = require("../services/videoFrameToolValidation");

describe("video frame tool chain contract", () => {
  test("sorts compatible tools and keeps their parameters", () => {
    const tools = validateTools([
      { position: 2, procedure: "saturation", params: { saturationFactor: 1.2 } },
      { position: 0, procedure: "brightness", params: { brightness: 1.1 } },
    ]);
    expect(tools).toEqual([
      { position: 0, procedure: "brightness", params: { brightness: 1.1 } },
      { position: 2, procedure: "saturation", params: { saturationFactor: 1.2 } },
    ]);
  });

  test("rejects duplicate positions and non-image tools", () => {
    expect(() => validateTools([
      { position: 0, procedure: "brightness", params: {} },
      { position: 0, procedure: "contrast", params: {} },
    ])).toThrow("VIDEO_FRAME_TOOL_INVALID_ORDER");
    expect(() => validateTools([{ position: 0, procedure: "people_ai", params: {} }]))
      .toThrow("VIDEO_FRAME_TOOL_INCOMPATIBLE");
  });
});