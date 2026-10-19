const assert = require("assert");
const { validateVideo } = require("../services/videoValidation");

assert.doesNotThrow(() => validateVideo({
  container: "mp4", videoCodec: "h264", audioCodec: "aac",
  size: 1, duration: 1, width: 1, height: 1, fps: 30,
}, "registered"));
assert.throws(
  () => validateVideo({
    container: "avi", videoCodec: "h264", audioCodec: null,
    size: 1, duration: 1, width: 1, height: 1, fps: 30,
  }, "registered"),
  (error) => error.message === "VIDEO_VALIDATION_FAILED" && error.failures.includes("container"),
);
