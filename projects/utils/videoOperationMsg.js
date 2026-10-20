function operationEvent(operation, overrides = {}) {
  const event = {
    operationId: String(operation._id),
    type: operation.type,
    status: overrides.status || operation.status,
    progress: overrides.progress ?? operation.progress ?? 0,
    resultVideoId: overrides.resultVideoId ?? operation.result_video_id ?? null,
    errorCode: overrides.errorCode ?? operation.error_code ?? null,
  };
  if (operation.type === "frame_extract") {
    event.targetProjectId = overrides.targetProjectId ?? operation.target_project_id ?? null;
    event.estimatedFrames = overrides.estimatedFrames ?? operation.estimated_frames ?? null;
    event.extractedFrames = overrides.extractedFrames ?? operation.extracted_frames ?? 0;
    event.outputFormat = overrides.outputFormat ?? operation.output_format ?? null;
  }
  return event;
}

function cancellationMessage(operation) {
  return { operationId: String(operation._id), type: operation.type, action: "cancel" };
}

module.exports = { operationEvent, cancellationMessage };
