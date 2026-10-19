const assert = require("assert");
const { toPublicVideoError } = require("../services/videoErrors");

assert.strictEqual(toPublicVideoError(new Error("VIDEO_METADATA_INVALID")).code, "VIDEO_VALIDATION_FAILED");
assert.strictEqual(toPublicVideoError(new Error("VIDEO_STORAGE_FAILED")).code, "VIDEO_STORAGE_FAILED");
assert.strictEqual(toPublicVideoError(new Error("VIDEO_ANALYZER_UNAVAILABLE")).message.includes("temporariamente"), true);

const batch = [
  { fileName: "ok.mp4", status: "concluída" },
  { fileName: "bad.mp4", status: "rejeitada" },
];
assert.deepStrictEqual(batch.map((item) => item.status), ["concluída", "rejeitada"]);
