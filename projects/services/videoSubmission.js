const FormData = require("form-data");
const fs = require("fs");
const path = require("path");
const { readVideoMetadata } = require("./videoMetadata");
const { validateVideo } = require("./videoValidation");
const { cleanupVideoFile } = require("./videoCleanup");
const { toPublicVideoError } = require("./videoErrors");
const Project = require("../controllers/project");
const { post_video } = require("../utils/videoStorage");

function toSubmissionResponse(projectId, updatedProject) {
  const storedReference = updatedProject.videos.at(-1);
  return {
    id: String(storedReference._id),
    projectId: String(projectId),
    metadata: storedReference,
    version: updatedProject.version,
  };
}

async function submitVideo({ req, project, expectedVersion, profile = "registered" }) {
  const file = req.file;
  let storedObjectKey;
  try {
    const duplicate = (project.videos || []).find((video) => video.name === file.originalname);
    const duplicateAction = req.body?.duplicateAction || "cancel";
    if (duplicate && duplicateAction !== "keep") {
      const error = new Error("VIDEO_DUPLICATE");
      error.status = 409;
      throw error;
    }
    const metadata = validateVideo(await readVideoMetadata(file), profile === "premium" ? "premium" : "registered");
    const form = new FormData();
    form.append("video", fs.createReadStream(file.path), {
      filename: file.originalname,
      contentType: file.mimetype || "video/mp4",
    });
    const storageResponse = await post_video(project.user_id, project._id, form);
    storedObjectKey = storageResponse.data.data.imageKey;
    const reference = {
      user_id: project.user_id,
      project_id: project._id,
      stage: "video-src",
      object_key: storedObjectKey,
      name: file.originalname,
      size: metadata.size,
      duration: metadata.duration,
      width: metadata.width,
      height: metadata.height,
      fps: metadata.fps,
      container: metadata.container,
      videoCodec: metadata.videoCodec,
      audioCodec: metadata.audioCodec,
      sha256: metadata.sha256,
    };
    const updatedProject = await Project.appendVideoIfVersion(
      project.user_id,
      project._id,
      reference,
      expectedVersion,
    );
    if (!updatedProject) {
      const error = new Error("PROJECT_VERSION_CONFLICT");
      error.status = 409;
      throw error;
    }
    return toSubmissionResponse(project._id, updatedProject);
  } catch (error) {
    if (storedObjectKey) {
      try {
        const { delete_video } = require("../utils/videoStorage");
        await delete_video(project.user_id, project._id, storedObjectKey);
      } catch (cleanupError) {
        console.error("Failed to clean up stored video:", cleanupError.message);
      }
    }
    if (error.message === "PROJECT_VERSION_CONFLICT" || error.message === "VIDEO_DUPLICATE") throw error;
    const publicError = toPublicVideoError(error);
    const wrapped = new Error(publicError.code);
    wrapped.publicError = publicError;
    throw wrapped;
  } finally {
    await cleanupVideoFile(file);
  }
}

module.exports = { submitVideo, toSubmissionResponse };
