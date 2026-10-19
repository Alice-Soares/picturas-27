const assert = require("assert");

const success = {
  id: "video-reference-id",
  projectId: "project-id",
  metadata: {
    container: "mp4",
    videoCodec: "h264",
    audioCodec: "aac",
    size: 1,
    duration: 1,
    width: 1920,
    height: 1080,
    fps: 30,
  },
};

assert.ok(success.id);
assert.ok(success.projectId);
assert.strictEqual(success.metadata.container, "mp4");
assert.strictEqual(success.metadata.videoCodec, "h264");
assert.ok(Number.isFinite(success.metadata.duration));
