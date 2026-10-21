// Executar a partir da raiz do repositório:
// node --test projects/test/videoMergeValidation.test.js
const test = require("node:test");
const assert = require("node:assert/strict");
const { validateMergeSelection } = require("../services/videoMergeValidation");

const makeVideo = (id, duration) => ({
  _id: id,
  duration,
  object_key: `videos/${id}.mp4`,
});
const videos = Array.from({ length: 16 }, (_, i) => makeVideo(String(i + 1), 60));
const check = (videoIds, profile = "registered", projectVideos = videos) =>
  validateMergeSelection({ videoIds, profile, projectVideos });
const ids = (count) => Array.from({ length: count }, (_, i) => String(i + 1));

test("mantém a ordem indicada e soma as durações", () => {
  const result = check(["3", "1", "2"]);
  assert.deepEqual(result.videos.map((video) => String(video._id)), ["3", "1", "2"]);
  assert.equal(result.totalDurationSeconds, 180);
});

test("exige pelo menos dois vídeos", () => {
  assert.throws(() => check(["1"]), /VIDEO_MERGE_TOO_FEW_VIDEOS/);
  assert.throws(() => check([]), /VIDEO_MERGE_TOO_FEW_VIDEOS/);
});

test("registado permite cinco vídeos mas não seis", () => {
  assert.equal(check(ids(5)).videos.length, 5);
  assert.throws(() => check(ids(6)), /VIDEO_MERGE_TOO_MANY_VIDEOS/);
});

test("premium permite quinze vídeos mas não dezasseis", () => {
  assert.equal(check(ids(15), "premium").videos.length, 15);
  assert.throws(() => check(ids(16), "premium"), /VIDEO_MERGE_TOO_MANY_VIDEOS/);
});

test("registado permite exatamente 300 segundos e rejeita mais", () => {
  const set = [makeVideo("a", 150), makeVideo("b", 150.01)];
  assert.equal(check(["a", "b"], "registered", [set[0], { ...set[1], duration: 150 }]).totalDurationSeconds, 300);
  assert.throws(() => check(["a", "b"], "registered", set), /VIDEO_MERGE_DURATION_EXCEEDED/);
});

test("premium permite exatamente 1800 segundos e rejeita mais", () => {
  const exact = [makeVideo("a", 900), makeVideo("b", 900)];
  assert.equal(check(["a", "b"], "premium", exact).totalDurationSeconds, 1800);
  assert.throws(() => check(["a", "b"], "premium", [exact[0], makeVideo("b", 901)]), /VIDEO_MERGE_DURATION_EXCEEDED/);
});

test("não permite vídeos inexistentes no projeto", () => {
  assert.throws(() => check(["1", "not-in-project"]), /VIDEO_MERGE_NOT_FOUND/);
});

test("não permite metadados inválidos nem referências de armazenamento vazias", () => {
  assert.throws(() => check(["a", "b"], "registered", [makeVideo("a", NaN), makeVideo("b", 10)]), /VIDEO_MERGE_INVALID_VIDEO/);
  assert.throws(() => check(["a", "b"], "registered", [makeVideo("a", 10), { ...makeVideo("b", 10), object_key: "" }]), /VIDEO_MERGE_INVALID_VIDEO/);
});

test("rejeita utilizadores não autorizados", () => {
  assert.throws(() => check(["1", "2"], "anonymous"), /VIDEO_MERGE_UNAUTHORIZED/);
});
