"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const { registerVideoMergeRoutes, normalizeMergeProfile } = require("../routes/videoMergeRoutes");

const makeRes = () => ({
  statusCode: 200,
  status(n) { this.statusCode = n; return this; },
  json(v) { this.body = v; return this; },
});
function setup({ profile = "free", caller = "owner", service } = {}) {
  const routes = [];
  const router = { post: (path, middleware, handler) => routes.push({path, middleware, handler}) };
  const calls = [];
  const mockService = service || {createMergeOperation: async (request) => {
    calls.push(request);
    return {_id: "op1", status: "queued"};
  }};
  registerVideoMergeRoutes(router, {
    requireAuth: (_req, _res, next) => next(),
    getCallerId: () => caller,
    getProfile: async () => profile,
    service: mockService,
  });
  return { route: routes[0], calls };
}
const req = { params: {user: "owner", project: "p1"}, body: {videoIds: ["v2", "v1"]} };
test("a rota cria operação com 202 mantendo ordem e perfil gratuito normalizado", async () => {
  const {route,calls} = setup(); const res = makeRes();
  assert.equal(route.path, "/:user/:project/video-merge");
  await route.handler(req,res);
  assert.equal(res.statusCode,202);
  assert.deepEqual(res.body, { operationId: "op1", status: "queued" });
  assert.deepEqual(calls[0], {userId:"owner",projectId:"p1",videoIds:["v2","v1"],profile:"registered"});
});
test("premium preservado, anonymous não convertido", () => {
  assert.equal(normalizeMergeProfile("premium"),"premium");
  assert.equal(normalizeMergeProfile("anonymous"),"anonymous");
});
test("outro utilizador não pode criar concatenação", async () => {
  const {route,calls}=setup({caller:"intruso"}); const res=makeRes();
  await route.handler(req,res);
  assert.equal(res.statusCode,403);
  assert.deepEqual(calls,[]);
});
test("erros de quota ficam públicos e erros internos não vazam", async () => {
  for (const [err,status,code] of [
    [Object.assign(new Error("VIDEO_MERGE_QUOTA_EXCEEDED"),{status:429}),429,"VIDEO_MERGE_QUOTA_EXCEEDED"],
    [new Error("internal connection string"),500,"VIDEO_MERGE_FAILED"],
  ]) {
    const {route}=setup({service:{createMergeOperation:async()=>{throw err;}}}); const res=makeRes();
    await route.handler(req,res);
    assert.deepEqual([res.statusCode,res.body.error],[status,code]);
  }
});
