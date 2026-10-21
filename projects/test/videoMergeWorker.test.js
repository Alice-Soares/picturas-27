'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { createVideoMergeWorker, selectSources, parseMergeQueueMessage } = require('../services/videoMergeWorker');

function createHarness(overrides = {}) {
  const calls = [];
  const operation = {
    _id: 'op1', type: 'merge', user_id: 'user1', project_id: 'proj1',
    source_video_ids: ['v2', 'v1'], status: 'processing',
  };
  let status = 'processing';
  const dependencies = {
    claim: async () => { calls.push('claim'); return operation; },
    status: async () => status,
    project: async () => ({ videos: [
      { _id: 'v1', object_key: 'obj1' }, { _id: 'v2', object_key: 'obj2' },
    ] }),
    pipeline: async ({ videos, onProgress, checkCancelled }) => {
      calls.push(`merge:${videos.map((video) => video._id).join(',')}`);
      await checkCancelled();
      onProgress(55);
      return { savedResult: { videoId: 'new1' } };
    },
    progress: async (_id, value) => { calls.push(`progress:${value}`); return null; },
    complete: async (_id, videoId) => { calls.push(`complete:${videoId}`); return { ...operation, status: 'completed' }; },
    fail: async (_id, error) => { calls.push(`fail:${error.message}`); return { ...operation, status: 'failed' }; },
    undoSaved: async (_operation, result) => { calls.push(`undo:${result.savedResult.videoId}`); },
    publish: async (op) => { calls.push(`publish:${op.status}`); },
    ...overrides,
  };
  return { calls, operation, dependencies, setStatus: (value) => { status = value; } };
}

test('processa IDs na ordem da operação e conclui com o novo vídeo', async () => {
  const h = createHarness();
  assert.deepEqual(await createVideoMergeWorker(h.dependencies).runMergeOperation('op1'), { completed: true, videoId: 'new1' });
  assert.ok(h.calls.includes('merge:v2,v1'));
  assert.ok(h.calls.includes('complete:new1'));
  assert.ok(h.calls.includes('publish:completed'));
});

test('claim inexistente não executa novamente mensagens duplicadas', async () => {
  const h = createHarness({ claim: async () => null });
  assert.deepEqual(await createVideoMergeWorker(h.dependencies).runMergeOperation('op1'), { skipped: true });
  assert.deepEqual(h.calls, []);
});

test('fonte removida marca erro sem iniciar concatenação', async () => {
  const h = createHarness({ project: async () => ({ videos: [{ _id: 'v1', object_key: 'obj1' }] }) });
  const result = await createVideoMergeWorker(h.dependencies).runMergeOperation('op1');
  assert.deepEqual(result, { failed: true, errorCode: 'VIDEO_MERGE_SOURCE_REMOVED' });
  assert.ok(h.calls.some((v) => v.startsWith('fail:')));
  assert.ok(!h.calls.some((v) => v.startsWith('merge:')));
});

test('erro na pipeline marca falha em vez de concluir', async () => {
  const h = createHarness({ pipeline: async () => { throw new Error('ffmpeg indisponível'); } });
  const result = await createVideoMergeWorker(h.dependencies).runMergeOperation('op1');
  assert.deepEqual(result, { failed: true, errorCode: 'VIDEO_MERGE_FAILED' });
  assert.ok(!h.calls.some((v) => v.startsWith('complete:')));
});

test('cancelamento anterior ao processamento não executa a pipeline', async () => {
  const h = createHarness();
  h.setStatus('cancelled');
  const result = await createVideoMergeWorker(h.dependencies).runMergeOperation('op1');
  assert.deepEqual(result, { cancelled: true });
  assert.ok(!h.calls.some((v) => v.startsWith('merge:')));
});

test('cancelamento durante FFmpeg ativa o AbortSignal', async () => {
  const h = createHarness({
    pipeline: ({ signal }) => new Promise((resolve, reject) => {
      signal.addEventListener('abort', () => reject(Object.assign(new Error('abortado'), { name: 'AbortError' })), { once: true });
    }),
  });
  const testInterval = setTimeout(() => h.setStatus('cancelled'), 12);
  const result = await createVideoMergeWorker(h.dependencies, { pollMs: 5 }).runMergeOperation('op1');
  clearTimeout(testInterval);
  assert.deepEqual(result, { cancelled: true });
  assert.ok(!h.calls.some((v) => v.startsWith('fail:')));
});

test('não conclui se o cancelamento acontecer depois da pipeline', async () => {
  const h = createHarness({ pipeline: async () => { h.setStatus('cancelled'); return { savedResult: { videoId: 'new1' } }; } });
  const result = await createVideoMergeWorker(h.dependencies).runMergeOperation('op1');
  assert.deepEqual(result, { cancelled: true });
  assert.ok(!h.calls.some((v) => v.startsWith('complete:')));
  assert.ok(h.calls.includes('undo:new1'));
});

test('valida payloads RabbitMQ sem correr serviços', () => {
  assert.equal(parseMergeQueueMessage({ content: Buffer.from('{"operationId":"abc"}') }), 'abc');
  assert.equal(parseMergeQueueMessage({ content: Buffer.from('{"foo":1}') }), null);
  assert.equal(parseMergeQueueMessage({ content: Buffer.from('invalid') }), null);
});

test('rejeita seleção com menos de 2 vídeos ou sem key', () => {
  assert.throws(() => selectSources({ source_video_ids: ['v1'] }, { videos: [{_id:'v1', object_key:'x'}] }), /NOT_FOUND/);
  assert.throws(() => selectSources({ source_video_ids: ['v1','v2'] }, { videos: [{_id:'v1', object_key:'x'}, {_id:'v2'}] }), /SOURCE_REMOVED/);
});

test('falha de finalização após guardar resultado executa compensação', async () => {
  const h = createHarness({
    complete: async () => null,
  });
  const result = await createVideoMergeWorker(h.dependencies).runMergeOperation('op1');
  assert.deepEqual(result, { cancelled: true });
  assert.ok(h.calls.includes('undo:new1'));
});
