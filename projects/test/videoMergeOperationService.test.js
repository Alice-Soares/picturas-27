"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const { createVideoMergeOperationService, publicMergeError } = require("../services/videoMergeOperationService");

function video(id, duration = 30) {
  return { _id: id, duration, object_key: `video-src/${id}.mp4` };
}
function setup(overrides = {}) {
  const calls = [];
  let saved = null;
  let creation = 0;
  const deps = {
    getProject: async () => ({ videos: [video("a"), video("b"), video("c")] }),
    reserveQuota: async (_id, profile) => { calls.push("reserve"); return profile !== "premium"; },
    createOperation: async (record) => {
      calls.push("create"); creation += 1;
      saved = { _id: "op-" + creation, ...record };
      return saved;
    },
    enqueue: async (operationId) => { calls.push(`enqueue:${operationId}`); },
    publish: async (operation) => { calls.push(`publish:${operation.status}`); },
    refundQuota: async () => { calls.push("refund"); },
    setQuotaRefunded: async () => { calls.push("refunded"); },
    failQueued: async () => { calls.push("failQueued"); },
    findOperation: async () => saved,
    setCancelled: async () => {
      if (!saved || !["queued", "processing"].includes(saved.status)) return null;
      saved.status = "cancelled";
      return saved;
    },
    ...overrides,
  };
  return { service: createVideoMergeOperationService(deps), calls, getSaved: () => saved };
}
const request = { userId: "user", projectId: "project", videoIds: ["b", "a"], profile: "registered" };

test("regista operação merge com IDs na ordem indicada antes de enfileirar", async () => {
  const x = setup();
  const op = await x.service.createMergeOperation(request);
  assert.equal(op.type, "merge");
  assert.deepEqual(op.source_video_ids, ["b", "a"]);
  assert.equal(op.total_duration_seconds, 60);
  assert.deepEqual(x.calls, ["reserve", "create", "enqueue:op-1", "publish:queued"]);
});
test("premium não reserva quota", async () => {
  const x = setup();
  const op = await x.service.createMergeOperation({ ...request, profile: "premium" });
  assert.equal(op.quota_reserved, false);
});
test("seleção inválida falha antes de reservar quota", async () => {
  const x = setup();
  await assert.rejects(x.service.createMergeOperation({ ...request, videoIds: ["a"] }), /VIDEO_MERGE_TOO_FEW_VIDEOS/);
  assert.deepEqual(x.calls, []);
});
test("projeto inacessível impede criação", async () => {
  const x = setup({ getProject: async () => null });
  await assert.rejects(x.service.createMergeOperation(request), /VIDEO_MERGE_UNAUTHORIZED/);
  assert.deepEqual(x.calls, []);
});
test("erro a criar registo repõe quota", async () => {
  const x = setup({ createOperation: async () => { throw Error("DB_DOWN"); } });
  await assert.rejects(x.service.createMergeOperation(request), /DB_DOWN/);
  assert.deepEqual(x.calls, ["reserve", "refund"]);
});
test("falha ao enfileirar assinala erro e repõe quota", async () => {
  const x = setup({ enqueue: async () => { throw Error("QUEUE_DOWN"); } });
  await assert.rejects(x.service.createMergeOperation(request), /QUEUE_DOWN/);
  assert.deepEqual(x.calls, ["reserve", "create", "failQueued", "refund", "refunded"]);
});
test("consulta só devolve operação encontrada", async () => {
  const x = setup();
  await assert.rejects(x.service.getMergeOperation("u", "p", "inexistente"), /VIDEO_MERGE_NOT_FOUND/);
  await x.service.createMergeOperation(request);
  assert.equal((await x.service.getMergeOperation("u", "p", "op-1"))._id, "op-1");
});
test("cancelamento marca estado, reembolsa e notifica", async () => {
  const x = setup();
  await x.service.createMergeOperation(request);
  x.calls.length = 0;
  const op = await x.service.cancelMergeOperation("user", "project", "op-1");
  assert.equal(op.status, "cancelled");
  assert.deepEqual(x.calls, ["refund", "refunded", "publish:cancelled"]);
});
test("cancelamento repetido não reembolsa segunda vez", async () => {
  const x = setup();
  await x.service.createMergeOperation(request);
  await x.service.cancelMergeOperation("user", "project", "op-1");
  x.calls.length = 0;
  await x.service.cancelMergeOperation("user", "project", "op-1");
  assert.deepEqual(x.calls, ["publish:cancelled"]);
});
test("operação concluída não pode ser cancelada", async () => {
  const x = setup();
  const op = await x.service.createMergeOperation(request);
  op.status = "completed";
  x.calls.length = 0;
  const result = await x.service.cancelMergeOperation("user", "project", "op-1");
  assert.equal(result.status, "completed");
  assert.deepEqual(x.calls, []);
});
test("só códigos previstos são divulgados ao cliente", () => {
  assert.equal(publicMergeError(new Error("VIDEO_MERGE_NOT_FOUND")), "VIDEO_MERGE_NOT_FOUND");
  assert.equal(publicMergeError(new Error("Mongo connection refused")), "VIDEO_MERGE_FAILED");
});
