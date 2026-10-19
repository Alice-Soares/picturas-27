const VideoOperation = require("../models/videoOperation");

describe("video operation contract", () => {
  test("exposes the documented states and required fields", () => {
    const schema = VideoOperation.schema;
    expect(schema.path("status").enumValues).toEqual([
      "queued", "processing", "completed", "failed", "cancelled",
    ]);
    for (const field of ["type", "user_id", "project_id", "source_video_id", "start_seconds", "end_seconds"]) {
      expect(schema.path(field).isRequired).toBe(true);
    }
  });
});
