# Contract: video frame extraction

## Create operation

`POST /projects/:user/:project/video/:videoId/frame-extract`

```json
{
  "startSeconds": 0,
  "endSeconds": 2,
  "maxFrames": 100,
  "outputFormat": "jpeg",
  "targetProjectId": "optional-project-id"
}
```

Successful response: `202`.

```json
{
  "operationId": "operation-id",
  "status": "queued",
  "estimatedFrames": 48,
  "maxFrames": 100,
  "outputFormat": "jpeg"
}
```

## Get operation

`GET /projects/:user/:project/video-operations/:operationId`

The response includes type, state, progress, source/destination IDs, interval,
frame counts, format, public frame results only after `completed`, and a public
error code when applicable. Temporary paths and storage internals are never
returned.

## Cancel operation

`POST /projects/:user/:project/video-operations/:operationId/cancel`

Cancellation is idempotent for terminal states and returns the operation state.

## RabbitMQ

- Exchange: `picturas`.
- Queue: `video_frame_extract`.
- Message: `{ "operationId": "..." }`.

## WebSocket

Events use the existing `project-op` envelope. `op.type` is `frame_extract` and
contains operation ID, state, progress, target project, estimated/extracted
counts, format and public error code. Temporary object keys are excluded.

## Public errors

`VIDEO_FRAME_EXTRACT_UNAUTHORIZED`, `VIDEO_FRAME_EXTRACT_NOT_FOUND`,
`VIDEO_FRAME_EXTRACT_INVALID_INTERVAL`, `VIDEO_FRAME_EXTRACT_INVALID_MAX_FRAMES`,
`VIDEO_FRAME_EXTRACT_LIMIT_EXCEEDED`, `VIDEO_FRAME_EXTRACT_FORMAT_UNSUPPORTED`,
`VIDEO_FRAME_EXTRACT_QUOTA_EXCEEDED`, `VIDEO_FRAME_EXTRACT_NO_FRAMES` and
`VIDEO_FRAME_EXTRACT_FAILED`.
