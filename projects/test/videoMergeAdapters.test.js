"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  createVideoMergeStorageAdapter,
  createVideoMergeSaveResult,
} = require("../services/videoMergeAdapters");

function fakeStorage() {
  const calls = [];
  const adapter = createVideoMergeStorageAdapter({
    videoStorage: {
      async download_video(...args) { calls.push(["download", ...args]); },
      async post_video(...args) {
        calls.push(["upload", ...args]);
        return { data: { data: { imageKey: "123/p/video-src/result.mp4" } } };
      },
      async delete_video(...args) { calls.push(["delete", ...args]); },
    },
    formFactory: () => ({ append: (...args) => calls.push(["append", ...args]) }),
    createReadStream: (path) => ({ path, mocked: true }),
  });
  return { adapter, calls };
}

function fakeProjects(overrides = {}) {
  const calls = [];
  const current = {
    version: 7,
    videos: [{ _id: "a" }, { _id: "b" }],
  };
  const repository = {
    async getOne(...args) { calls.push(["get", ...args]); return current; },
    async appendVideoIfVersion(...args) {
      calls.push(["append", ...args]);
      return { videos: [...current.videos, { _id: "merged-1", ...args[2] }] };
    },
    ...overrides,
  };
  return { repository, calls };
}

const payload = () => ({
  userId: "u1", projectId: "p1", sourceVideoIds: ["b", "a"],
  objectKey: "123/p/video-src/merged.mp4", name: "concatenado.mp4",
  metadata: { size: 123, duration: 3, width: 640, height: 360, fps: 24,
    container: "mov,mp4", videoCodec: "h264", audioCodec: "aac", sha256: "sha" },
});

test("download usa a função de armazenamento existente e preserva objectKey", async () => {
  const { adapter, calls } = fakeStorage();
  await adapter.downloadVideo({ userId: "u1", projectId: "p1", objectKey: "folder/a.mp4", destination: "C:/tmp/a.mp4" });
  assert.deepEqual(calls, [["download", "u1", "p1", "folder/a.mp4", "C:/tmp/a.mp4"]]);
});

test("upload usa multipart de vídeo e converte imageKey em objectKey", async () => {
  const { adapter, calls } = fakeStorage();
  const result = await adapter.uploadVideo({ userId: "u1", projectId: "p1", filePath: "C:/tmp/merge.mp4", name: "concatenado.mp4" });
  assert.equal(result.objectKey, "123/p/video-src/result.mp4");
  assert.equal(calls[0][0], "append");
  assert.equal(calls[0][1], "video");
  assert.equal(calls[0][2].path, "C:/tmp/merge.mp4");
  assert.deepEqual(calls[0][3], { filename: "concatenado.mp4", contentType: "video/mp4" });
  assert.deepEqual(calls[1].slice(0, 3), ["upload", "u1", "p1"]);
});

test("remoção do objeto remoto usa delete_video existente", async () => {
  const { adapter, calls } = fakeStorage();
  await adapter.deleteVideo({ userId: "u1", projectId: "p1", objectKey: "key/result.mp4" });
  assert.deepEqual(calls, [["delete", "u1", "p1", "key/result.mp4"]]);
});

test("resultado é associado ao projeto com controlo de versão", async () => {
  const { repository, calls } = fakeProjects();
  const saveResult = createVideoMergeSaveResult({ projectRepository: repository });
  const result = await saveResult(payload());
  assert.equal(result.videoId, "merged-1");
  assert.equal(calls[1][0], "append");
  assert.equal(calls[1][4], 7);
  assert.equal(calls[1][3].object_key, "123/p/video-src/merged.mp4");
  assert.equal(calls[1][3].stage, "video-src");
  assert.equal(calls[1][3].user_id, "u1");
});

test("metadados não podem sobrescrever IDs, nome ou object_key", async () => {
  const { repository, calls } = fakeProjects();
  const data = payload();
  data.metadata.object_key = "evil";
  data.metadata.user_id = "evil";
  data.metadata.name = "evil";
  await createVideoMergeSaveResult({ projectRepository: repository })(data);
  assert.equal(calls[1][3].object_key, data.objectKey);
  assert.equal(calls[1][3].user_id, data.userId);
  assert.equal(calls[1][3].name, data.name);
});

test("rejeita projeto inexistente ou sem acesso", async () => {
  const { repository } = fakeProjects({ getOne: async () => null });
  await assert.rejects(createVideoMergeSaveResult({ projectRepository: repository })(payload()),
    (e) => e.message === "VIDEO_MERGE_UNAUTHORIZED" && e.status === 403);
});

test("rejeita origem removida antes da persistência", async () => {
  const { repository, calls } = fakeProjects();
  const data = payload(); data.sourceVideoIds = ["b", "missing"];
  await assert.rejects(createVideoMergeSaveResult({ projectRepository: repository })(data),
    /VIDEO_MERGE_SOURCE_REMOVED/);
  assert.equal(calls.some(([type]) => type === "append"), false);
});

test("falha em conflito de versão e não devolve falso sucesso", async () => {
  const { repository } = fakeProjects({ appendVideoIfVersion: async () => null });
  await assert.rejects(createVideoMergeSaveResult({ projectRepository: repository })(payload()),
    (e) => e.message === "VIDEO_MERGE_PROJECT_CONFLICT" && e.status === 409);
});

test("cancelamento impede a gravação no projeto", async () => {
  const { repository, calls } = fakeProjects();
  await assert.rejects(
    createVideoMergeSaveResult({ projectRepository: repository, checkCancelled: async () => { throw new Error("VIDEO_MERGE_CANCELLED"); } })(payload()),
    /VIDEO_MERGE_CANCELLED/,
  );
  assert.equal(calls.some(([type]) => type === "append"), false);
});

test("valida os parâmetros antes de persistir ou carregar", async () => {
  const { repository, calls } = fakeProjects();
  const saveResult = createVideoMergeSaveResult({ projectRepository: repository });
  await assert.rejects(saveResult({ ...payload(), sourceVideoIds: [] }), /VIDEO_MERGE_INVALID_SOURCES/);
  const { adapter } = fakeStorage();
  await assert.rejects(adapter.downloadVideo({ objectKey: "", destination: "foo" }), /VIDEO_MERGE_OBJECT_KEY_REQUIRED/);
  assert.equal(calls.length, 0);
});
