const express = require("express");
const multer = require("multer");
const uploadImage = require("../services/uploadImage");
const uploadVideo = require("../services/uploadVideo");

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });
const videoUpload = multer({ dest: "/tmp/picturas-video-storage" });
require("fs").mkdirSync("/tmp/picturas-video-storage", { recursive: true });

router.post(
  "/video/:userId/:projectId",
  videoUpload.single("video"),
  async (req, res) => {
    if (!req.file) return res.status(400).json({ error: "VIDEO_FILE_REQUIRED" });
    try {
      const result = await uploadVideo(req.params.userId, req.params.projectId, req.file);
      return res.status(201).json({ message: "Vídeo enviado com sucesso!", data: result });
    } catch (error) {
      return res.status(500).json({ error: "VIDEO_STORAGE_FAILED" });
    } finally {
      const fs = require("fs");
      fs.rm(req.file.path, { force: true }, () => {});
    }
  },
);

router.post(
  "/:userId/:projectId/:stage",
  upload.single("file"),
  async (req, res) => {
    const { userId, projectId, stage } = req.params;

    const allowedStages = require("../utils/stages");

    if (!allowedStages.includes(stage)) {
      return res.status(400).json({
        error: "O estágio deve ser src, preview, preview_cache ou out.",
      });
    }

    try {
      const result = await uploadImage(userId, projectId, req.file, stage);
      res
        .status(201)
        .json({ message: "Imagem enviada com sucesso!", data: result });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },
);

module.exports = router;
