function operationEvent(operation, overrides = {}) {
  return {
    operationId: String(operation._id),
    type: operation.type,
    status: overrides.status || operation.status,
    progress: overrides.progress ?? operation.progress ?? 0,
    resultVideoId: overrides.resultVideoId ?? operation.result_video_id ?? null,
    errorCode: overrides.errorCode ?? operation.error_code ?? null,
  };
}

function cancellationMessage(operation) {
  return { operationId: String(operation._id), type: operation.type, action: "cancel" };
}

module.exports = { operationEvent, cancellationMessage };
