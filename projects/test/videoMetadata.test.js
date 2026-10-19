const assert = require("assert");
const { readVideoMetadata } = require("../services/videoMetadata");

readVideoMetadata().catch((error) => {
  assert.strictEqual(error.message, "VIDEO_FILE_REQUIRED");
});
