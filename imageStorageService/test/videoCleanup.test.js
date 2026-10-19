const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { promisify } = require("util");

(async () => {
  const filePath = path.join(os.tmpdir(), `picturas-storage-cancel-${Date.now()}`);
  await fs.promises.writeFile(filePath, "partial");
  await promisify(fs.rm)(filePath, { force: true });
  await promisify(fs.rm)(filePath, { force: true });
  assert.strictEqual(fs.existsSync(filePath), false);
})();
