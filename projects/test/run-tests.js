const assert = require("assert");

let suite = [];
global.describe = (_name, callback) => callback();
global.test = (name, callback) => suite.push({ name, callback });
global.expect = (value) => ({
  toBe: (expected) => assert.strictEqual(value, expected),
  toEqual: (expected) => assert.deepStrictEqual(value, expected),
  toThrow: (expected) => {
    assert.strictEqual(typeof value, "function");
    assert.throws(value, expected ? new RegExp(expected) : undefined);
  },
});
global.expectAsync = (promise) => ({
  rejects: async (message) => {
    try {
      await promise;
      throw new Error("Expected promise to reject");
    } catch (error) {
      assert.strictEqual(error.message, message);
    }
  },
});

for (const file of [
  "videoTrimValidation.test.js",
  "videoOperationState.test.js",
  "videoOperationMsg.test.js",
  "videoOperation.contract.test.js",
  "videoFrameToolValidation.test.js",
  "videoFrameTool.contract.test.js",
  "videoFrameTool.chain.contract.test.js",
  "videoFrameToolFailure.test.js",
  "videoFrameTool.integration.test.js",
  "videoFrameExtractionValidation.test.js",
  "videoConversionValidation.test.js",
  "videoConversion.contract.test.js",
]) require(`./${file}`);

async function run() {
  let failures = 0;
  let passed = 0;
  for (const { name, callback } of suite) {
    try {
      await callback();
      console.log(`ok - ${name}`);
      passed += 1;
    } catch (error) {
      failures += 1;
      console.error(`not ok - ${name}`);
      console.error(error.stack || error.message);
    }
  }
  if (failures) process.exitCode = 1;
  else console.log(`\n${passed} tests passed`);
}

run().catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
