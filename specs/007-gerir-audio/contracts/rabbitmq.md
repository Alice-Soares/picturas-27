# RabbitMQ Contract

Procedure: `video_audio`. The durable queue and direct-exchange routing key are
`video_audio_queue`. `correlationId` equals the operation identifier. The
Projects Service declares and binds this queue before publishing, and confirms
the persistent request before closing its RabbitMQ connection.

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
