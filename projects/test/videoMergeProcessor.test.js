const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { buildMergeArgs, probeVideo, mergeLocalVideos } = require('../services/videoMergeProcessor');

function source(filePath, hasAudio = true) {
  return { path: filePath, width: 320, height: 180, fps: 25, duration: 1, hasAudio };
}

test('comando respeita a ordem dos vídeos e não altera os originais', () => {
  const args = buildMergeArgs([source('b.mp4'), source('a.mp4')], 'resultado.mp4');
  assert.deepEqual(args.filter((_, i) => args[i - 1] === '-i'), ['b.mp4', 'a.mp4']);
  assert.ok(args.includes('-n')); // Não substitui ficheiros existentes
  assert.ok(args.includes('resultado.mp4'));
  assert.ok(args.some((arg) => arg.includes('concat=n=2:v=1:a=1')));
});

test('prepara áudio silencioso se faltar faixa de áudio (decisão provisória Q2)', () => {
  const args = buildMergeArgs([source('a.mp4'), source('b.mp4', false)], 'resultado.mp4');
  assert.ok(args.includes('anullsrc=r=48000:cl=stereo'));
  assert.ok(args.some((arg) => arg.includes('[2:a:0]')));
});

test('recusa menos de dois vídeos', () => {
  assert.throws(() => buildMergeArgs([source('a.mp4')], 'resultado.mp4'), /TOO_FEW/);
});

const available = ['ffmpeg', 'ffprobe'].every((cmd) => {
  const probe = spawnSync(cmd, ['-version'], { stdio: 'ignore' });
  return probe.status === 0;
});

test('integração local: concatena dois vídeos com resoluções e áudio diferentes', { skip: !available && 'FFmpeg/FFprobe não instalados' }, async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'picturas-merge-test-'));
  try {
    const a = path.join(dir, 'a.mp4');
    const b = path.join(dir, 'b.mp4');
    const out = path.join(dir, 'joined.mp4');
    const gen1 = spawnSync('ffmpeg', ['-v', 'error', '-y', '-f', 'lavfi', '-i', 'color=c=red:s=320x180:r=25:d=1.2', '-f', 'lavfi', '-i', 'sine=frequency=440:sample_rate=48000:duration=1.2', '-shortest', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-c:a', 'aac', a], { encoding: 'utf8' });
    assert.equal(gen1.status, 0, gen1.stderr);
    const gen2 = spawnSync('ffmpeg', ['-v', 'error', '-y', '-f', 'lavfi', '-i', 'color=c=blue:s=640x360:r=30:d=1.3', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', b], { encoding: 'utf8' });
    assert.equal(gen2.status, 0, gen2.stderr);
    const progress = [];
    const result = await mergeLocalVideos({ inputPaths: [a, b], outputPath: out, onProgress: (p) => progress.push(p) });
    assert.equal(result.width, 320);
    assert.equal(result.height, 180);
    assert.ok(result.duration >= 2.3 && result.duration <= 3, `duração=${result.duration}`);
    assert.equal(result.hasAudio, true);
    assert.ok(progress.includes(100));
    assert.ok((await fs.stat(a)).size > 0);
    assert.ok((await fs.stat(b)).size > 0);
    assert.ok((await fs.stat(out)).size > 0);
    await assert.rejects(mergeLocalVideos({ inputPaths: [a, b], outputPath: a }), /OUTPUT_IS_SOURCE/);
  } finally {
    await fs.rm(dir, { recursive: true, force: true });
  }
});
