const s3 = require("./s3Client");

async function getPresignedUrlDocker(userId, projectId, stage, imageName) {
  const params = {
    Bucket: `user-${userId}`,
    Key: `${projectId}/${stage}/${imageName}`,
    Expires: 60 * 60,
  };

  try {
    return await s3.getSignedUrlPromise("getObject", params);
  } catch (error) {
    console.error("Erro ao gerar URL presignada:", error.message);
    throw error;
  }
}

async function getPresignedUrlHost(userId, projectId, stage, imageName) {
  const params = {
    Bucket: `user-${userId}`,
    Key: `${projectId}/${stage}/${imageName}`,
    Expires: 60 * 60,
  };

  try {
    const url = await s3.getSignedUrlPromise("getObject", params);
    const internal = `http://${process.env.S3_ENDPOINT || "seaweedfs:9000"}`;
    return url.replace(internal, process.env.FRONTEND_URL + '/s3');
  } catch (error) {
    console.error("Erro ao gerar URL presignada:", error.message);
    throw error;
  }
}

module.exports = { getPresignedUrlDocker, getPresignedUrlHost };
