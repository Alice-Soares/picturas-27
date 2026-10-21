"use strict";

// UC-VID-006 — Ponte entre a pipeline e a infraestrutura real do Projects Service.
// As dependências são recebidas por parâmetro para permitir testes sem Docker,
// MongoDB, RabbitMQ, FFmpeg ou node_modules.

function mergeError(code, status = 400) {
  const error = new Error(code);
  error.status = status;
  return error;
}

function requiredString(value, code) {
  if (typeof value !== "string" || !value.trim()) throw mergeError(code);
  return value;
}

/**
 * Adapta as funções existentes em projects/utils/videoStorage.js ao contrato
 * esperado por runVideoMergePipeline().
 */
function createVideoMergeStorageAdapter({ videoStorage, formFactory, createReadStream } = {}) {
  // Carregar só quando a função for usada: importar este módulo não exige npm install.
  const storage = () => videoStorage || require("../utils/videoStorage");
  const newForm = () => formFactory ? formFactory() : new (require("form-data"))();
  const streamFrom = (filePath) => createReadStream
    ? createReadStream(filePath)
    : require("fs").createReadStream(filePath);

  return {
    async downloadVideo({ userId, projectId, objectKey, destination }) {
      requiredString(objectKey, "VIDEO_MERGE_OBJECT_KEY_REQUIRED");
      requiredString(destination, "VIDEO_MERGE_DESTINATION_REQUIRED");
      await storage().download_video(userId, projectId, objectKey, destination);
    },

    async uploadVideo({ userId, projectId, filePath, name }) {
      requiredString(filePath, "VIDEO_MERGE_FILE_REQUIRED");
      requiredString(name, "VIDEO_MERGE_NAME_REQUIRED");
      const form = newForm();
      form.append("video", streamFrom(filePath), {
        filename: name,
        contentType: "video/mp4",
      });
      const response = await storage().post_video(userId, projectId, form);
      const objectKey = response?.data?.data?.imageKey;
      return { objectKey: requiredString(objectKey, "VIDEO_MERGE_UPLOAD_MISSING_KEY") };
    },

    async deleteVideo({ userId, projectId, objectKey }) {
      requiredString(objectKey, "VIDEO_MERGE_OBJECT_KEY_REQUIRED");
      await storage().delete_video(userId, projectId, objectKey);
    },
  };
}

/**
 * Adapta o controller já existente à persistência do resultado.
 * Carrega uma versão atual do projeto, verifica se os vídeos ainda existem e
 * usa appendVideoIfVersion para evitar sobrescrever alterações concorrentes.
 *
 * Nota: checkCancelled DEVE consultar o estado real da operação antes do save.
 * O cancelamento concorrente com a escrita não é atómico nesta fase do MVP.
 */
function createVideoMergeSaveResult({ projectRepository, checkCancelled = async () => {} } = {}) {
  if (checkCancelled && typeof checkCancelled !== "function") {
    throw new TypeError("checkCancelled deve ser uma função");
  }
  const projects = () => projectRepository || require("../controllers/project");

  return async function saveResult({
    userId, projectId, sourceVideoIds, objectKey, name, metadata,
  }) {
    requiredString(objectKey, "VIDEO_MERGE_OBJECT_KEY_REQUIRED");
    requiredString(name, "VIDEO_MERGE_NAME_REQUIRED");
    if (!Array.isArray(sourceVideoIds) || sourceVideoIds.length < 2) {
      throw mergeError("VIDEO_MERGE_INVALID_SOURCES");
    }
    if (!metadata || typeof metadata !== "object") {
      throw mergeError("VIDEO_MERGE_INVALID_METADATA");
    }

    await checkCancelled();
    const project = await projects().getOne(userId, projectId);
    if (!project) throw mergeError("VIDEO_MERGE_UNAUTHORIZED", 403);

    const existingIds = new Set((project.videos || []).map((v) => String(v._id)));
    if (sourceVideoIds.some((id) => !existingIds.has(String(id)))) {
      throw mergeError("VIDEO_MERGE_SOURCE_REMOVED", 409);
    }
    if (!Number.isInteger(project.version)) {
      throw mergeError("VIDEO_MERGE_INVALID_VERSION", 409);
    }

    // Estes campos correspondem aos campos obrigatórios do videoSchema.
    const video = {
      user_id: userId,
      project_id: projectId,
      stage: "video-src",
      object_key: objectKey,
      name,
      ...metadata,
    };
    // As propriedades fornecidas pelo cliente não podem substituir os IDs e
    // a referência no armazenamento que acabámos de atribuir.
    video.user_id = userId;
    video.project_id = projectId;
    video.stage = "video-src";
    video.object_key = objectKey;
    video.name = name;

    await checkCancelled();
    const updated = await projects().appendVideoIfVersion(
      userId, projectId, video, project.version,
    );
    if (!updated) throw mergeError("VIDEO_MERGE_PROJECT_CONFLICT", 409);

    // O schema project.videos ainda só tem sourceVideoId (singular).
    // A lista sourceVideoIds pertence à futura operação merge, não ao vídeo.
    const createdVideo = (updated.videos || [])[updated.videos.length - 1] || null;
    return { video: createdVideo, videoId: createdVideo?._id ? String(createdVideo._id) : null };
  };
}

module.exports = {
  createVideoMergeStorageAdapter,
  createVideoMergeSaveResult,
};
