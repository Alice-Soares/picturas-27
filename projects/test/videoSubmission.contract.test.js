const assert = require("assert");
const { toSubmissionResponse } = require("../services/videoSubmission");

describe("video submission response", () => {
  test("returns the identifier assigned to the stored video subdocument", () => {
    const response = toSubmissionResponse("project-id", {
      version: 4,
      videos: [{
        _id: "stored-video-id",
        container: "mp4",
        videoCodec: "h264",
        audioCodec: "aac",
        size: 1,
        duration: 1,
        width: 1920,
        height: 1080,
        fps: 30,
      }],
    });

    assert.strictEqual(response.id, "stored-video-id");
    assert.strictEqual(response.projectId, "project-id");
    assert.strictEqual(response.metadata._id, response.id);
    assert.strictEqual(response.version, 4);
  });
});
