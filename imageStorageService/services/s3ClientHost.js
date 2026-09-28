const AWS = require("aws-sdk");

// Client used to sign URLs that the browser will follow; the host part of the
// signed URL is rewritten to the public proxy path in getPresignedUrl.js.
const s3 = new AWS.S3({
  endpoint: `http://${process.env.S3_ENDPOINT || "seaweedfs:9000"}`,
  accessKeyId: process.env.S3_ACCESS_KEY || "admin",
  secretAccessKey: process.env.S3_SECRET_KEY || "admin123",
  s3ForcePathStyle: true,
  region: "us-east-1",
});

module.exports = s3;
