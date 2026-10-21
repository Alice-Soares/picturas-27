'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const { runVideoMergePipeline } = require('../services/videoMergePipeline');

const videos = [
  { _id: 'a', object_key: 'video-A.mp4' },
  { _id: 'b', object_key: 'video-B.mp4' },
];
const metadata = { size: 123, duration: 3, width: 320, height: 180, fps: 25, container: 'mp4', videoCodec: 'h264', audioCodec: 'aac', sha256: 'abc' };

async function sandbox(runTest) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), 'merge-pipeline-test-'));
  try { return await runTest(root); }
  finally { await fs.rm(root, { recursive: true, force: true }); }
}
function fakeDeps(root, options = {}) {
  const calls = [];
  const storage = {
    async downloadVideo({ objectKey, destination }) {
      calls.push(['download', objectKey, destination]);
      await fs.writeFile(destination, `dados:${objectKey}`);
    },
    async uploadVideo({ filePath, name }) {
      calls.push(['upload', name, await fs.readFile(filePath, 'utf8')]);
      if (options.abortOnUpload) options.controller.abort();
      return { objectKey: 'novo-resultado.mp4' };
    },
    async deleteVideo({ objectKey }) { calls.push(['delete', objectKey]); },
  };
  const processor = async ({ inputPaths, outputPath, onProgress }) => {
    calls.push(['processor', await Promise.all(inputPaths.map((p) => fs.readFile(p, 'utf8')))]);
    if (options.failProcessor) throw new Error('FFMPEG_FAILED');
    await fs.writeFile(outputPath, 'ficheiro-resultante');
    onProgress?.(42);
  };
  const metadataReader = async ({ path: outputPath }) => {
    calls.push(['metadata', path.basename(outputPath)]);
    return metadata;
  };
  const saveResult = async (input) => {
    calls.push(['save', input]);
    if (options.failSave) throw new Error('PROJECT_VERSION_CONFLICT');
    return { videoId: 'new-id' };
  };
  return { calls, storage, processor, metadataReader, saveResult, tempRoot: root };
}
const input = { userId: 'u1', projectId: 'p1', videos };

test('descarrega pela ordem, concatena, lê metadados e regista um novo vídeo', async () => sandbox(async (root) => {
  const deps = fakeDeps(root);
  const progress = [];
  const result = await runVideoMergePipeline({ ...input, ...deps, onProgress: (p) => progress.push(p) });
  assert.deepEqual(deps.calls.filter((c) => c[0] === 'download').map((c) => c[1]), ['video-A.mp4', 'video-B.mp4']);
  assert.deepEqual(deps.calls.find((c) => c[0] === 'processor')[1], ['dados:video-A.mp4', 'dados:video-B.mp4']);
  assert.deepEqual(deps.calls.map((c) => c[0]), ['download', 'download', 'processor', 'metadata', 'upload', 'save']);
  assert.deepEqual(deps.calls.find((c) => c[0] === 'save')[1].sourceVideoIds, ['a', 'b']);
  assert.deepEqual(progress, [42, 100]);
  assert.equal(result.objectKey, 'novo-resultado.mp4');
  assert.deepEqual(await fs.readdir(root), []); // temporários eliminados
}));

test('erro no FFmpeg não faz upload e limpa a pasta temporária', async () => sandbox(async (root) => {
  const deps = fakeDeps(root, { failProcessor: true });
  await assert.rejects(runVideoMergePipeline({ ...input, ...deps }), /FFMPEG_FAILED/);
  assert.ok(!deps.calls.some((c) => c[0] === 'upload'));
  assert.deepEqual(await fs.readdir(root), []);
}));

test('falha ao registar no projeto remove o ficheiro carregado', async () => sandbox(async (root) => {
  const deps = fakeDeps(root, { failSave: true });
  await assert.rejects(runVideoMergePipeline({ ...input, ...deps }), /PROJECT_VERSION_CONFLICT/);
  assert.deepEqual(deps.calls.filter((c) => c[0] === 'delete'), [['delete', 'novo-resultado.mp4']]);
  assert.deepEqual(await fs.readdir(root), []);
}));

test('cancelamento após upload remove o resultado remoto e não grava no projeto', async () => sandbox(async (root) => {
  const controller = new AbortController();
  const deps = fakeDeps(root, { abortOnUpload: true, controller });
  await assert.rejects(runVideoMergePipeline({ ...input, ...deps, signal: controller.signal }), /VIDEO_MERGE_CANCELLED/);
  assert.equal(deps.calls.some((c) => c[0] === 'save'), false);
  assert.deepEqual(deps.calls.filter((c) => c[0] === 'delete'), [['delete', 'novo-resultado.mp4']]);
  assert.deepEqual(await fs.readdir(root), []);
}));

test('rejeita seleção inválida sem executar processamento', async () => sandbox(async (root) => {
  const deps = fakeDeps(root);
  await assert.rejects(runVideoMergePipeline({ ...input, ...deps, videos: [videos[0]] }), /INVALID_SELECTION/);
  assert.equal(deps.calls.length, 0);
  assert.deepEqual(await fs.readdir(root), []);
}));
