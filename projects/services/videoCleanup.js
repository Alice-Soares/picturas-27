const fs = require("fs");

async function cleanupVideoFile(file) {
  if (!file?.path) return;
  await fs.promises.rm(file.path, { force: true });
}

module.exports = { cleanupVideoFile };
