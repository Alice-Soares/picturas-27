const { AUDIO_QUEUE, audioRequest, isAudioMessage } = require("../utils/videoAudioMsg");
const { operationEvent } = require("../utils/videoOperationMsg");
const VideoOperation = require("../models/videoOperation");
const Project = require("../models/project");

test("TST-AUD-001 audio worker request is correlated and exposes only the internal contract", () => {
  const request = audioRequest({ operation: { _id: "op1", audio_action: "extract", audio_start_seconds: null, audio_end_seconds: null }, inputVideoURI: "/app/images/in.mp4", outputURI: "/app/images/out.m4a" });
  expect(request.procedure).toBe("video_audio");
  expect(request.correlationId).toBe("op1");
  expect(request.parameters.action).toBe("extract");
  expect(AUDIO_QUEUE).toBe("video_audio_queue");
  expect(isAudioMessage(request)).toBe(true);
  expect(isAudioMessage({ procedure: "video_audio" })).toBe(false);
});

test("TST-AUD-005 audio action and project audio content are represented in the data model", () => {
  expect(VideoOperation.schema.path("type").enumValues.includes("audio")).toBe(true);
  expect(VideoOperation.schema.path("audio_action").isRequired).toBe(true);
  expect(Project.schema.path("audios").instance).toBe("Array");
  for (const field of ["sourceVideoId", "stage", "object_key", "name", "size", "duration", "container", "audioCodec", "sampleRate", "channels"]) {
    expect(Project.schema.path("audios").schema.path(field) !== undefined).toBe(true);
  }
});

test("TST-AUD-002 audio operation event includes action and result audio id", () => {
  const event = operationEvent({ _id: "op2", type: "audio", audio_action: "extract", status: "completed", progress: 100, result_audio_id: "audio1" });
  expect(event.audioAction).toBe("extract");
  expect(event.resultAudioId).toBe("audio1");
  expect(JSON.stringify(event).includes("/app/images")).toBe(false);
});
