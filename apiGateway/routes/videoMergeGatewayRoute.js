"use strict";

// API Gateway: apenas encaminha pedidos autenticados para o Projects Service.
function registerVideoMergeGatewayRoute(router, {
  checkToken,
  axios,
  projectsURL,
  httpsAgent,
  forwardAxiosError,
} = {}) {
  if (typeof checkToken !== "function" || !axios || typeof forwardAxiosError !== "function") {
    throw new TypeError("UC-VID-006: dependências do Gateway em falta");
  }
  router.post("/:user/:project/video-merge", checkToken, async (req, res) => {
    // A UC-VID-006 permite apenas ao dono criar uma concatenação.
    if (String(req.authUserId) !== String(req.params.user)) {
      return res.status(403).json({ error: "VIDEO_MERGE_UNAUTHORIZED" });
    }
    try {
      const response = await axios.post(
        `${projectsURL}${req.params.user}/${req.params.project}/video-merge`,
        { videoIds: req.body?.videoIds },
        {
          httpsAgent,
          headers: {
            Authorization: req.headers["authorization"],
            "X-Caller-Id": req.authUserId,
            "X-User-Profile": req.authUserType,
          },
        },
      );
      return res.status(response.status).json(response.data);
    } catch (error) {
      return forwardAxiosError(res, error, "Falha ao iniciar concatenação de vídeos");
    }
  });
}

module.exports = { registerVideoMergeGatewayRoute };
