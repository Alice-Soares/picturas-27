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

for (const file of [
  "videoTrimValidation.test.js",
  "videoOperationState.test.js",
  "videoOperationMsg.test.js",
  "videoOperation.contract.test.js",
]) require(`./${file}`);

let failures = 0;
for (const { name, callback } of suite) {
  try {
    callback();
    console.log(`ok - ${name}`);
  } catch (error) {
    failures += 1;
    console.error(`not ok - ${name}`);
    console.error(error.stack || error.message);
  }
}
if (failures) process.exitCode = 1;
else console.log(`\n${suite.length} tests passed`);
