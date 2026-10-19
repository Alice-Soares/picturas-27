const assert = require("assert");
const { validateVideo } = require("../services/videoValidation");

const valid = {
  container: "mov,mp4", videoCodec: "h264", audioCodec: "aac",
  size: 100_000_000, duration: 300, width: 1920, height: 1080, fps: 60,
};

assert.doesNotThrow(() => validateVideo(valid, "registered"));
for (const [field, value] of [["container", "avi"], ["videoCodec", "vp9"], ["audioCodec", "opus"]]) {
  assert.throws(() => validateVideo({ ...valid, [field]: value }, "registered"));
}
assert.throws(() => validateVideo({ ...valid, width: 1921 }, "registered"));
assert.throws(() => validateVideo({ ...valid, size: 100_000_001 }, "registered"));
assert.throws(() => validateVideo({ ...valid, duration: 301 }, "registered"));
assert.throws(() => validateVideo({ ...valid, fps: 61 }, "registered"));
