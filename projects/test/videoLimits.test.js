const assert = require("assert");
const { DECIMAL_MB, DECIMAL_GB, validateVideoLimits } = require("../services/videoLimits");

assert.strictEqual(DECIMAL_MB, 1_000_000);
assert.strictEqual(DECIMAL_GB, 1_000_000_000);
assert.deepStrictEqual(
  validateVideoLimits({ size: 100_000_000, duration: 300, width: 1920, height: 1080, fps: 60 }, "registered"),
  [],
);
assert.deepStrictEqual(
  validateVideoLimits({ size: 100_000_000, duration: 300, width: 1921, height: 1080, fps: 60 }, "registered"),
  ["resolution"],
);
