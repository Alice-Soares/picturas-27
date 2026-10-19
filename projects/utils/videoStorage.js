const axios = require("axios");
const fs = require("fs");
const storageUrl = "http://img_storage:11000";

async function post_video(user, project, form) {
  return axios.post(`${storageUrl}/upload/video/${user}/${project}`, form, {
    headers: form.getHeaders(),
    maxContentLength: Infinity,
    maxBodyLength: Infinity,
  });
}

async function delete_video(user, project, objectKey) {
  const fileName = objectKey.split("/").pop();
  return axios.delete(`${storageUrl}/delete/${user}/${project}/video-src/${fileName}`);
}

async function download_video(user, project, objectKey, destination) {
  const fileName = objectKey.split("/").pop();
  const response = await axios.get(
    `${storageUrl}/image/internal/${user}/${project}/video-src/${fileName}`,
  );
  const stream = await axios.get(response.data.url, { responseType: "stream" });
  await new Promise((resolve, reject) => {
    const output = fs.createWriteStream(destination);
    stream.data.pipe(output);
    output.on("finish", resolve);
    output.on("error", reject);
    stream.data.on("error", reject);
  });
  return destination;
}

module.exports = { post_video, delete_video, download_video };
