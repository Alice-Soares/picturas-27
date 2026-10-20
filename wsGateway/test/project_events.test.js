const assert = require("assert");
const { emitProjectOperation } = require("../utils/project_events");

const calls = [];
const io = { to: (room) => ({ emit: (event, payload) => calls.push({ room, event, payload }) }) };
const operation = { operationId: "op-1", type: "frame_tool", status: "processing" };

assert.strictEqual(emitProjectOperation(io, { projectId: "project-1", op: operation }), true);
assert.deepStrictEqual(calls, [{
  room: "project:project-1",
  event: "project-op",
  payload: { projectId: "project-1", op: operation },
}]);

const invalidIo = { to: () => ({ emit: () => { throw new Error("should not emit"); } }) };
assert.strictEqual(emitProjectOperation(invalidIo, { projectId: "project-1" }), false);
console.log("project event routing tests passed");