"use strict";

// Endpoint de criação da UC-VID-006. Consulta e cancelamento reutilizam
// as rotas genéricas de video-operations já existentes.
const { createVideoMergeOperationService, publicMergeError } = require("../services/videoMergeOperationService");

function normalizeMergeProfile(profile) {
  // Users-MS usa 'free'; os requisitos da UC usam 'registered'.
  return profile === "free" ? "registered" : profile;
}

function registerVideoMergeRoutes(router, {
  requireAuth,
  getCallerId,
  getProfile,
  service = createVideoMergeOperationService(),
} = {}) {
  if (typeof requireAuth !== "function" || typeof getCallerId !== "function" || typeof getProfile !== "function") {
    throw new TypeError("UC-VID-006: middlewares obrigatórios em falta");
  }
  router.post("/:user/:project/video-merge", requireAuth, async (req, res) => {
    if (String(getCallerId(req)) !== String(req.params.user)) {
      return res.status(403).json({ error: "VIDEO_MERGE_UNAUTHORIZED" });
    }
    try {
      const operation = await service.createMergeOperation({
        userId: req.params.user,
        projectId: req.params.project,
        videoIds: req.body?.videoIds,
        profile: normalizeMergeProfile(await getProfile(req)),
      });
      return res.status(202).json({ operationId: String(operation._id), status: operation.status });
    } catch (error) {
      const code = publicMergeError(error);
      const status = Number.isInteger(error.status) && error.status >= 400 && error.status <= 599
        ? error.status
        : code === "VIDEO_MERGE_FAILED" ? 500 : 400;
      return res.status(status).json({ error: code });
    }
  });
}

module.exports = { registerVideoMergeRoutes, normalizeMergeProfile };
