const { v4: uuidv4 } = require("uuid");

function conversionRequest({ operation, inputVideoURI, outputVideoURI }) {
  return {
    messageId: `video-conversion-${operation._id}-${uuidv4()}`,
    correlationId: String(operation._id),
    timestamp: new Date().toISOString(),
    procedure: "video_conversion",
    parameters: {
      inputVideoURI,
      outputVideoURI,
      options: {
        outputContainer: operation.output.outputContainer,
        outputVideoCodec: operation.output.outputVideoCodec,
        outputAudioCodec: operation.output.outputAudioCodec,
        outputWidth: operation.output.outputWidth,
        outputHeight: operation.output.outputHeight,
      },
    },
  };
}

function isConversionMessage(message) {
  return message?.procedure === "video_conversion" && Boolean(message.correlationId);
}

module.exports = { conversionRequest, isConversionMessage };
