const VideoOperation = require("../models/videoOperation");
const { operationEvent } = require("../utils/videoOperationMsg");

describe("video frame tool contract", () => {
  test("accepts the frame tool operation type and fields", () => {
    const schema = VideoOperation.schema;
    expect(schema.path("type").enumValues.includes("frame_tool")).toBe(true);
    for (const field of ["output_fps", "tools", "frame_attempts"]) {
      expect(Boolean(schema.path(field))).toBe(true);
    }
  });

  test("publishes a safe operation event", () => {
    const event = operationEvent({
      _id: "operation-1",
      type: "frame_tool",
      status: "processing",
      progress: 40,
      result_video_id: null,
      error_code: null,
    });
    expect(event).toEqual({
      operationId: "operation-1",
      type: "frame_tool",
      status: "processing",
      progress: 40,
      resultVideoId: null,
      errorCode: null,
    });
  });
});