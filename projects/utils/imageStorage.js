const axios = require("axios");

const fs = require("fs");

const key = fs.readFileSync(__dirname + "/../certs/selfsigned.key");
const cert = fs.readFileSync(__dirname + "/../certs/selfsigned.crt");

const https = require("https");
const httpsAgent = new https.Agent({
  rejectUnauthorized: false, // (NOTE: this will disable client verification)
  cert: cert,
  key: key,
});

const img_storage_ms = "http://img_storage:11000";

async function get_image_internal_url(user, project, type, img) {
  return await axios.get(
    `${img_storage_ms}/image/internal/${user}/${project}/${type}/${img}` /* , { httpsAgent: httpsAgent } */,
  );
}

async function get_image_public_url(user, project, type, img) {
  return await axios.get(
    `${img_storage_ms}/image/public/${user}/${project}/${type}/${img}` /* , { httpsAgent: httpsAgent } */,
  );
}

async function post_image(user, project, type, file) {
  return await axios.post(
    `${img_storage_ms}/upload/${user}/${project}/${type}`,
    file,
    {
      ...(typeof file?.getHeaders === "function" ? { headers: file.getHeaders() } : {}),
      maxContentLength: Infinity,
      maxBodyLength: Infinity,
    },
  );
}

async function post_extracted_image(user, project, file) {
  return post_image(user, project, "src", file);
}

async function delete_image(user, project, type, img) {
  return await axios.delete(
    `${img_storage_ms}/delete/${user}/${project}/${type}/${img}` /* , { httpsAgent: httpsAgent } */,
  );
}

async function copy_image(userId, projectId, fromStage, toStage, fileName) {
  // usa o mesmo serviço interno (docker network) tal como as outras
  return axios.post(
    `${img_storage_ms}/copy/${userId}/${projectId}/${fromStage}/${toStage}/${fileName}`,
    {}
  );
}

async function download_content(user, project, type, objectKey, destination) {
  const fileName = objectKey.split("/").pop();
  const response = await axios.get(`${img_storage_ms}/image/internal/${user}/${project}/${type}/${fileName}`);
  const stream = await axios.get(response.data.url, { responseType: "stream" });
  await new Promise((resolve, reject) => {
    const output = fs.createWriteStream(destination);
    stream.data.pipe(output);
    output.on("finish", resolve); output.on("error", reject); stream.data.on("error", reject);
  });
  return destination;
}

const post_audio = (user, project, form) => post_image(user, project, "audio-src", form);
const delete_audio = (user, project, objectKey) => delete_image(user, project, "audio-src", objectKey.split("/").pop());
const download_audio = (user, project, objectKey, destination) => download_content(user, project, "audio-src", objectKey, destination);

module.exports = { get_image_internal_url, get_image_public_url, post_image, post_extracted_image, delete_image, copy_image, download_content, post_audio, delete_audio, download_audio };
