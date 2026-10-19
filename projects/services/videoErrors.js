function toPublicVideoError(error) {
  const code = error.message === "VIDEO_STORAGE_FAILED"
    ? "VIDEO_STORAGE_FAILED"
    : error.message === "VIDEO_ANALYZER_UNAVAILABLE"
      ? "VIDEO_ANALYZER_UNAVAILABLE"
      : error.message === "VIDEO_FILE_REQUIRED"
        ? "VIDEO_FILE_REQUIRED"
        : error.message === "VIDEO_FILE_TOO_LARGE"
          ? "VIDEO_FILE_TOO_LARGE"
        : "VIDEO_VALIDATION_FAILED";
  const messages = {
    VIDEO_FILE_REQUIRED: "É necessário selecionar um vídeo.",
    VIDEO_ANALYZER_UNAVAILABLE: "A validação de vídeo está temporariamente indisponível.",
    VIDEO_STORAGE_FAILED: "Não foi possível guardar o vídeo.",
    VIDEO_VALIDATION_FAILED: "O vídeo não cumpre os requisitos de formato ou do perfil.",
    VIDEO_FILE_TOO_LARGE: "O vídeo excede o tamanho máximo permitido.",
  };
  return { code, message: messages[code] };
}

module.exports = { toPublicVideoError };
