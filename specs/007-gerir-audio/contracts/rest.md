# REST API Contract

Base path: `/:user/:project/video/:videoId`. Authentication and caller/project
authorization are required before reading media.

## Operations

- `POST /:user/:project/video/:videoId/audio/remove` — no body.
- `POST /:user/:project/video/:videoId/audio/replace` — multipart `audio` with
  MP3, M4A/AAC or a video containing a decodable audio stream, plus optional
  `startSeconds` and `endSeconds`. For video input, only the first audio stream
  is used; its video stream is ignored.
- `POST /:user/:project/video/:videoId/audio/extract` — no body.

For video input, replacement detects video/audio streams with FFprobe rather
than trusting the extension or MIME type. Audio-only input remains limited to
MP3 and M4A/AAC. A successful request returns `202`:

```json
{ "operationId": "string", "status": "queued" }
```

Invalid authorization, source, format, interval, quota or no-audio
precondition returns a stable safe `4xx` code and does not queue work.

Existing shared endpoints remain:

- `GET /:user/:project/video-operations/:operationId`, returning
  `type: "audio"`, `audioAction`, status, progress, result IDs and safe error.
- `GET /:user/:project/video-operations/:operationId/audio-download` streams
  the completed extraction as `audio.m4a`; the temporary file is removed after
  transfer. It is available only to the authorized project owner.
- `POST /:user/:project/video-operations/:operationId/cancel`, returning `202`
  with operation ID and current/terminal status.

Public errors never include credentials, storage paths, FFmpeg stderr or stacks.
