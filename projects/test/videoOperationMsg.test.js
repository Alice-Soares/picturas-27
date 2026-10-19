const { operationEvent, cancellationMessage } = require("../utils/videoOperationMsg");

describe("video operation messages", () => {
  const operation = {
    _id: "op-1",
    type: "trim",
    status: "processing",
    progress: 25,
    result_video_id: null,
  };

  test("creates a public operation event", () => {
    expect(operationEvent(operation)).toEqual({
      operationId: "op-1",
      type: "trim",
      status: "processing",
      progress: 25,
      resultVideoId: null,
      errorCode: null,
    });
  });

  test("creates a cancellation command", () => {
    expect(cancellationMessage(operation)).toEqual({
      operationId: "op-1",
      type: "trim",
      action: "cancel",
    });
  });
});
