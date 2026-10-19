const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { cleanupVideoFile } = require("../services/videoCleanup");

(async () => {
  const filePath = path.join(os.tmpdir(), `picturas-video-${Date.now()}`);
  await fs.promises.writeFile(filePath, "temporary");
  await cleanupVideoFile({ path: filePath });
  assert.strictEqual(fs.existsSync(filePath), false);
})();
