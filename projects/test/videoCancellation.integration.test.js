const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { cleanupVideoFile } = require("../services/videoCleanup");

(async () => {
  const filePath = path.join(os.tmpdir(), `picturas-cancel-${Date.now()}`);
  await fs.promises.writeFile(filePath, "partial");
  await cleanupVideoFile({ path: filePath });
  await cleanupVideoFile({ path: filePath });
  assert.strictEqual(fs.existsSync(filePath), false);
})();
