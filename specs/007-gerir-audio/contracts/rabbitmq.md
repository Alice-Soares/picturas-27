# RabbitMQ Contract

Routing key and procedure: `video_audio`. `correlationId` equals the operation
identifier.

```json
{
  "messageId": "video-audio-<operation>-<uuid>",
  "correlationId": "<operation-id>",
  "procedure": "video_audio",
  "parameters": {
    "action": "remove|replace|extract",
    "inputVideoURI": "/app/images/<temporary-input>",
    "replacementAudioURI": "/app/images/<temporary-audio-or-null>",
    "outputURI": "/app/images/<temporary-output>",
    "audioStartSeconds": 0,
    "audioEndSeconds": 10
  }
}
```

The worker rejects invalid actions, missing inputs and paths outside its shared
media directory. It emits `processing` progress, `completed` with validated
metadata, or `error` with a stable public code. Internal paths are never sent
to clients.
