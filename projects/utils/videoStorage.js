const axios = require("axios");
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

module.exports = { post_video, delete_video };
