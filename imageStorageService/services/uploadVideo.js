const fs = require("fs");
const s3 = require("./s3Client");
const createBucket = require("./createBucket");
const { v4: uuidv4 } = require("uuid");

async function uploadVideo(userId, projectId, file, stage = "video-src") {
  if (!file || !file.path) throw new Error("VIDEO_FILE_REQUIRED");

  const bucketName = `user-${userId}`;
  await createBucket(bucketName);
  const extension = (file.originalname || "video.mp4").split(".").pop().toLowerCase();
  const imageKey = `${projectId}/${stage}/${uuidv4()}.${extension}`;

  try {
    const data = await s3.upload({
      Bucket: bucketName,
      Key: imageKey,
      Body: fs.createReadStream(file.path),
      ContentType: file.mimetype || "video/mp4",
    }).promise();
    return { imageKey, location: data.Location };
  } catch (error) {
    console.error("Erro ao enviar vídeo:", error.message);
    throw error;
  }
}

module.exports = uploadVideo;
