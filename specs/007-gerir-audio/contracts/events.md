# Project Event Contract

Authorized project WebSocket events contain:

```json
{
  "operationId": "string",
  "type": "audio",
  "audioAction": "remove|replace|extract",
  "status": "queued|processing|completed|failed|cancelled",
  "progress": 0,
  "resultVideoId": "string|null",
  "resultAudioId": "string|null",
  "errorCode": "string|null"
}
```

Events are scoped to the authorized project. Temporary object keys, local paths,
input file names and internal diagnostics are excluded. Operations longer than
five seconds publish at least one progress event.
