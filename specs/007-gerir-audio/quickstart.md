# Quickstart: Validar Gestão de Áudio

## Prerequisites

Start the relevant services:

```bash
docker compose up -d --build projects video_audio_tool img_storage rabbitmq
docker compose exec projects ffprobe -version
docker compose ps rabbitmq projects video_audio_tool
```

Create an authenticated registered user and project, then add one MP4 with AAC
audio and one MP4 without audio using the existing upload flow.

## Focused automated validation

Run:

```bash
docker compose exec projects npm test
```

Add focused `TST-AUD-*` coverage for formats, intervals, no-audio rejection,
operation/message contracts, output metadata, authorization, quota, progress,
cancellation, failure and cleanup.

## Acceptance flows

### Remove

Call `POST /:user/:project/video/:videoId/audio/remove`, expect `202`, poll the
shared operation endpoint, and verify a new silent video while the source is
unchanged. Repeat for a source without audio and verify no result or quota use.

### Replace

Call the multipart replace endpoint with MP3, M4A/AAC and a video containing
audio. Verify video input contributes only its first audio stream, while the
result keeps the target video's picture and has MP4/AAC output. Also verify
source preservation, safe rejection of invalid/no-audio inputs, and the
shorter/longer interval semantics.

### Extract

Call `POST /:user/:project/video/:videoId/audio/extract` for a source with audio.
Verify the M4A/AAC download starts on the client and no audio item is added to
the project library. Repeat without audio and verify safe rejection, no result
and no quota use.

## Failure and authorization

Try anonymous, invalid-session and cross-project access for every action.
Exhaust registered-user quota and verify no operation is queued. Cancel during
processing and force a worker failure; verify terminal state, no partial item,
cleaned temporaries, preserved source and refunded quota. Confirm authorized
WebSocket progress and absence of events in an unauthorized project channel.

Record command output, operation IDs, result IDs and pass/fail outcomes in the
Phase 1 report; do not claim validation without running the relevant flow.
