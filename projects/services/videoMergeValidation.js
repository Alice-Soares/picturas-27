// UC-VID-006 — Validação local da seleção de vídeos.
// Dependências externas: nenhuma. O acesso ao projeto, quota e objetos armazenados
// devem ser verificados na camada de serviço antes de criar a operação.

const MERGE_LIMITS = Object.freeze({
  registered: Object.freeze({ maxVideos: 5, maxDurationSeconds: 5 * 60 }),
  premium: Object.freeze({ maxVideos: 15, maxDurationSeconds: 30 * 60 }),
});

function mergeError(code, status = 400) {
  const error = new Error(code);
  error.status = status;
  return error;
}

/**
 * Valida a seleção ordenada de vídeos de um projeto.
 * @param {object} args
 * @param {string[]} args.videoIds - IDs pela ordem pretendida pelo utilizador.
 * @param {Array} args.projectVideos - Subdocumentos project.videos.
 * @param {'registered'|'premium'} args.profile - Perfil autenticado.
 * @returns {{videos: Array, totalDurationSeconds: number, maxVideos: number, maxDurationSeconds: number}}
 */
function validateMergeSelection({ videoIds, projectVideos, profile }) {
  const limits = MERGE_LIMITS[profile];
  if (!limits) throw mergeError("VIDEO_MERGE_UNAUTHORIZED", 403);

  if (!Array.isArray(videoIds) || videoIds.length < 2) {
    throw mergeError("VIDEO_MERGE_TOO_FEW_VIDEOS");
  }
  if (videoIds.length > limits.maxVideos) {
    throw mergeError("VIDEO_MERGE_TOO_MANY_VIDEOS");
  }
  if (!Array.isArray(projectVideos)) {
    throw mergeError("VIDEO_MERGE_INVALID_PROJECT_VIDEOS");
  }

  // Conservar a ordem escolhida pelo utilizador, sem ordenar os IDs.
  const videos = videoIds.map((id) => {
    if (typeof id !== "string" || !id.trim()) {
      throw mergeError("VIDEO_MERGE_INVALID_VIDEO");
    }
    const video = projectVideos.find((item) => String(item._id) === id);
    if (!video) throw mergeError("VIDEO_MERGE_NOT_FOUND", 404);
    if (!Number.isFinite(video.duration) || video.duration <= 0 ||
        typeof video.object_key !== "string" || !video.object_key.trim()) {
      throw mergeError("VIDEO_MERGE_INVALID_VIDEO");
    }
    return video;
  });

  const totalDurationSeconds = videos.reduce((sum, video) => sum + video.duration, 0);
  if (totalDurationSeconds > limits.maxDurationSeconds) {
    throw mergeError("VIDEO_MERGE_DURATION_EXCEEDED");
  }

  return {
    videos,
    totalDurationSeconds,
    maxVideos: limits.maxVideos,
    maxDurationSeconds: limits.maxDurationSeconds,
  };
}

module.exports = { MERGE_LIMITS, validateMergeSelection };
