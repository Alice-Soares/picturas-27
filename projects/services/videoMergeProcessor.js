// UC-VID-006 — Núcleo local FFmpeg. Não usa Docker, MongoDB, RabbitMQ nem npm.
// Os caminhos recebidos são LOCAIS: o worker da aplicação tratará do download/upload.
const fs = require('node:fs/promises');
const path = require('node:path');
const { spawn } = require('node:child_process');

function run(command, args, { signal, onProgress, totalDuration } = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      shell: false,
      windowsHide: true,
      stdio: ['ignore', 'pipe', 'pipe'],
      signal,
    });
    const stdout = [];
    let stderr = '';
    let progressBuffer = '';
    let settled = false;
    const finish = (error, value) => {
      if (settled) return;
      settled = true;
      if (error) reject(error);
      else resolve(value);
    };
    child.stdout.on('data', (chunk) => stdout.push(chunk));
    child.stderr.on('data', (chunk) => {
      const str = String(chunk);
      stderr = (stderr + str).slice(-4000);
      if (!onProgress) return;
      progressBuffer = (progressBuffer + str).slice(-8192);
      const lines = progressBuffer.split(/\r?\n/);
      progressBuffer = lines.pop() || '';
      for (const line of lines) {
        if (!line.startsWith('out_time_us=')) continue;
        const elapsed = Number(line.split('=')[1]) / 1e6;
        if (Number.isFinite(elapsed) && totalDuration > 0) {
          onProgress(Math.min(99, Math.max(0, Math.round(100 * elapsed / totalDuration))));
        }
      }
    });
    child.on('error', (error) => finish(error));
    child.on('close', (code, sig) => {
      if (code === 0) finish(null, Buffer.concat(stdout).toString());
      else finish(new Error(`${command} falhou (${sig || code}): ${stderr.slice(-900)}`));
    });
  });
}

async function probeVideo(filePath, { signal } = {}) {
  const raw = await run('ffprobe', [
    '-v', 'error', '-show_streams', '-show_format', '-of', 'json', filePath,
  ], { signal });
  const details = JSON.parse(raw);
  const video = (details.streams || []).find((s) => s.codec_type === 'video');
  const audio = (details.streams || []).some((s) => s.codec_type === 'audio');
  const duration = Number(details.format?.duration);
  if (!video || !Number.isFinite(duration) || duration <= 0) {
    throw new Error('VIDEO_MERGE_INVALID_SOURCE');
  }
  const frameRate = String(video.avg_frame_rate || video.r_frame_rate || '0/0');
  const [num, den = '1'] = frameRate.split('/').map(Number);
  const fps = num / den;
  if (![video.width, video.height, fps].every((v) => Number.isFinite(v) && v > 0)) {
    throw new Error('VIDEO_MERGE_INVALID_METADATA');
  }
  return { path: filePath, duration, width: video.width, height: video.height, fps, hasAudio: audio };
}

function buildMergeArgs(sources, outputPath) {
  if (!Array.isArray(sources) || sources.length < 2) throw new Error('VIDEO_MERGE_TOO_FEW_VIDEOS');
  const first = sources[0];
  const width = 2 * Math.ceil(first.width / 2);
  const height = 2 * Math.ceil(first.height / 2);
  const fps = Math.round(first.fps * 1000) / 1000;
  const args = ['-hide_banner', '-nostdin', '-n'];
  for (const src of sources) args.push('-i', src.path);
  const silenceIndices = new Map();
  for (let i = 0; i < sources.length; i++) {
    if (sources[i].hasAudio) continue;
    silenceIndices.set(i, sources.length + silenceIndices.size);
    args.push('-f', 'lavfi', '-t', String(sources[i].duration), '-i', 'anullsrc=r=48000:cl=stereo');
  }
  const filters = [];
  for (let i = 0; i < sources.length; i++) {
    const src = sources[i];
    filters.push(
      `[${i}:v:0]setpts=PTS-STARTPTS,` +
      `scale=${width}:${height}:force_original_aspect_ratio=decrease:force_divisible_by=2,` +
      `pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2,setsar=1,` +
      `fps=${fps},format=yuv420p[v${i}]`,
    );
    const audioInput = src.hasAudio ? `${i}:a:0` : `${silenceIndices.get(i)}:a:0`;
    filters.push(
      `[${audioInput}]aresample=48000,aformat=channel_layouts=stereo,` +
      `asetpts=PTS-STARTPTS,apad,atrim=duration=${src.duration}[a${i}]`,
    );
  }
  filters.push(
    sources.map((_, i) => `[v${i}][a${i}]`).join('') +
    `concat=n=${sources.length}:v=1:a=1[vout][aout]`,
  );
  args.push(
    '-filter_complex', filters.join(';'),
    '-map', '[vout]', '-map', '[aout]',
    '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '23',
    '-c:a', 'aac', '-b:a', '128k',
    '-movflags', '+faststart', '-progress', 'pipe:2',
    '-nostats', '-loglevel', 'error', outputPath,
  );
  return args;
}

/** Recebe >=2 ficheiros locais e cria um novo MP4. Nunca modifica os originais. */
async function mergeLocalVideos({ inputPaths, outputPath, signal, onProgress }) {
  if (!Array.isArray(inputPaths) || inputPaths.length < 2) {
    throw new Error('VIDEO_MERGE_TOO_FEW_VIDEOS');
  }
  if (!outputPath || typeof outputPath !== 'string') throw new Error('VIDEO_MERGE_OUTPUT_REQUIRED');
  const inputs = inputPaths.map((input) => path.resolve(input));
  const output = path.resolve(outputPath);
  if (inputs.includes(output)) throw new Error('VIDEO_MERGE_OUTPUT_IS_SOURCE');
  try {
    await fs.access(output);
    throw new Error('VIDEO_MERGE_OUTPUT_EXISTS');
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  for (const input of inputs) {
    if (!(await fs.stat(input)).isFile()) throw new Error('VIDEO_MERGE_INVALID_SOURCE');
  }
  const sources = [];
  for (const input of inputs) sources.push(await probeVideo(input, { signal }));
  const totalDuration = sources.reduce((sum, s) => sum + s.duration, 0);
  try {
    await run('ffmpeg', buildMergeArgs(sources, output), { signal, onProgress, totalDuration });
    const result = await probeVideo(output, { signal });
    onProgress?.(100);
    return result;
  } catch (error) {
    await fs.rm(output, { force: true });
    throw error;
  }
}

module.exports = { probeVideo, buildMergeArgs, mergeLocalVideos };
