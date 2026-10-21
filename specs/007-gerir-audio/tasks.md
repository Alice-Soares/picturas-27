# Tasks: Gestão de Áudio de Vídeo

**Input**: Design documents from `/specs/007-gerir-audio/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md),
[research.md](./research.md), [data-model.md](./data-model.md),
[contracts/](./contracts/)

**Tests**: Included because the specification requires requirement-to-test
traceability and the quickstart defines focused contract, integration and
worker validation.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the new audio worker and shared test/documentation surfaces
without changing existing image processing.

- [ ] T001 [P] Create `Tools/video_audio/` with `video_audio.py`, `Dockerfile`, and `requirements.txt` following the existing `Tools/video_conversion/` layout
- [ ] T002 [P] Add `video_audio_tool` service to `docker-compose.yaml` with healthy RabbitMQ dependency, `elk` network, matching credentials, and `image_data:/app/images` volume
- [ ] T003 [P] Add audio operation contract fixtures in `projects/test/fixtures/videoAudioFixtures.js` for remove, replace, extract, MP3, M4A/AAC, no-audio and unsupported-format cases
- [ ] T004 [P] Add the `TST-AUD-*` test file entries to `projects/test/run-tests.js` without removing or renaming existing video tests

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared operation, authenticated download, temporary
media, error and message foundations required by all three user stories.

- [ ] T005 Extend `projects/models/videoOperation.js` with `type: "audio"` and required `audio_action: "remove" | "replace" | "extract"` while preserving all existing operation types and lifecycle states
- [ ] T006 Extend `projects/models/videoOperation.js` with nullable replacement-input fields, `audio_start_seconds`, `audio_end_seconds`, audio output metadata, and a private temporary download path for extraction results
- [ ] T007 Add the authenticated Projects Service `audio-download` stream endpoint and its API Gateway proxy; remove the temporary result after transfer
- [ ] T008 [P] Add `projects/services/videoAudioErrors.js` mapping internal failures to safe public codes without storage paths, credentials, FFmpeg stderr or stack traces
- [ ] T009 [P] Add `projects/services/videoAudioValidation.js` to accept only MP3 and M4A/AAC, validate media content with FFprobe, reject unsupported/corrupt input, and validate optional intervals against detected audio duration
- [ ] T010 [P] Add `projects/utils/videoAudioMsg.js` with correlated `video_audio` requests and response recognition; keep all worker paths internal
- [ ] T011 [P] Extend `projects/utils/videoOperationMsg.js` with `audioAction` and `resultAudioId` while preserving existing event fields and operation types
- [ ] T012 [P] Ensure temporary audio outputs use the shared media volume and are removed after download or expiry; do not persist extraction output through the project storage façade
- [ ] T013 Add foundational model, validation, message, authenticated download, shared-volume cleanup and error contract tests in focused `videoAudio*.test.js` files
- [ ] T014 Run `node projects/test/run-tests.js` and fix only regressions caused by the foundational model, event and storage changes before starting user-story work

**Checkpoint**: Shared audio operation, authenticated download, temporary cleanup,
safe errors and message contracts are available; user stories can be developed
independently.

## Phase 3: User Story 1 - Remover áudio de um vídeo (Priority: P1) 🎯 MVP

**Goal**: Let an authorized user create a new silent video without modifying
the source, including no-audio, cancellation, quota and cleanup behavior.

**Independent Test**: Submit remove for a video with audio, observe queued and
processing state, verify a new silent video and unchanged source; repeat for a
video without audio and for cancellation.

### Tests for User Story 1

- [ ] T015 [P] [US1] Add contract tests in `projects/test/videoAudioRemove.contract.test.js` for the remove request, `audioAction: "remove"`, correlated RabbitMQ payload, result video ID and safe public errors
- [ ] T016 [P] [US1] Add integration tests in `projects/test/videoAudioRemove.integration.test.js` for authorized creation, no-audio rejection without quota use, cancellation/refund, failed cleanup and immutable source
- [ ] T017 [P] [US1] Add worker tests in `Tools/video_audio/test_video_audio.py` proving remove output has no audio stream and incomplete output is deleted

### Implementation for User Story 1

- [ ] T018 [US1] Implement remove FFmpeg processing in `Tools/video_audio/video_audio.py` using explicit video mapping and audio removal, path validation inside `/app/images`, metadata response, progress events and stable errors
- [ ] T019 [US1] Implement `dispatchAudio` and correlated response handling for remove in `projects/services/videoAudioDispatcher.js`, including temporary input/output cleanup, timeout failure, result upload and `Project.appendVideoIfVersion`
- [ ] T020 [US1] Extend `projects/services/videoOperationService.js` with authorized remove creation, registered-user quota reservation, premium bypass, no-audio precondition, operation publication, failure/refund and cancellation cleanup
- [ ] T021 [US1] Add `POST /:user/:project/video/:videoId/audio/remove` to `projects/routes/projects.js`, reusing caller authorization and safe audio errors, returning `202` with `operationId` and status
- [ ] T022 [US1] Extend the shared operation response and cancellation dispatch in `projects/routes/projects.js` for `type: "audio"` and remove operations without changing existing trim/frame/conversion behavior
- [ ] T023 [US1] Start the audio dispatcher/response consumer in `projects/app.js` and route `video_audio` messages without changing existing RabbitMQ consumers
- [ ] T024 [US1] Add the remove action and queued/processing/terminal progress display to `frontend/components/project-page/video-audio-dialog.tsx` and expose it from `frontend/components/project-page/project-video-list.tsx`
- [ ] T025 [US1] Add remove-operation API and mutation helpers in `frontend/lib/projects.ts` and `frontend/lib/mutations/projects.ts`, including polling and cancellation
- [ ] T026 [US1] Run the US1 tests and the existing regression suite; record `TST-AUD-001` through `TST-AUD-006` results in the implementation evidence

**Checkpoint**: User Story 1 is independently demonstrable and is the
recommended MVP increment.

## Phase 4: User Story 2 - Substituir áudio de um vídeo (Priority: P1)

**Goal**: Let an authorized user upload MP3 or M4A/AAC, optionally select an
audio interval, and create an MP4/AAC result with the specified duration rules.

**Independent Test**: Replace audio with MP3 and M4A/AAC, verify MP4/AAC output,
reject unsupported input before queueing, and verify shorter/longer semantics.

### Tests for User Story 2

- [ ] T027 [P] [US2] Add replacement validation tests in `projects/test/videoAudioReplaceValidation.test.js` for MP3, M4A/AAC, unsupported/corrupt files, optional intervals and quota-not-reserved-on-rejection
- [ ] T028 [P] [US2] Add replacement integration tests in `projects/test/videoAudioReplace.integration.test.js` for multipart upload, MP4/AAC result, shorter audio remainder silence, longer audio clipping, cancellation and partial-result cleanup
- [ ] T029 [P] [US2] Extend `Tools/video_audio/test_video_audio.py` with MP3/M4A replacement, AAC output, shorter-input duration preservation and longer-input clipping assertions

### Implementation for User Story 2

- [ ] T030 [US2] Implement replacement input staging and cleanup in `projects/services/videoAudioDispatcher.js`, ensuring the uploaded temporary audio is removed after success, failure or cancellation
- [ ] T031 [US2] Extend `projects/services/videoOperationService.js` with replacement creation that validates project/video before reading input, accepts only MP3 or M4A/AAC, validates `audio_start_seconds`/`audio_end_seconds`, then reserves quota and queues work
- [ ] T032 [US2] Implement replacement FFmpeg processing in `Tools/video_audio/video_audio.py` with explicit video/audio mapping, AAC encoding, audio clipping at video duration, and video-duration preservation when replacement audio is shorter
- [ ] T033 [US2] Add `POST /:user/:project/video/:videoId/audio/replace` multipart handling in `projects/routes/projects.js` with bounded upload cleanup, optional interval parsing and safe validation errors
- [ ] T034 [US2] Add replacement controls, file selection, interval fields and validation messages to `frontend/components/project-page/video-audio-dialog.tsx`
- [ ] T035 [US2] Extend `frontend/lib/projects.ts` and `frontend/lib/mutations/projects.ts` with multipart replacement submission, polling and cancellation
- [ ] T036 [US2] Run US1 regression plus US2 contract, integration and worker tests; record `TST-AUD-007` through `TST-AUD-012` results

**Checkpoint**: User Stories 1 and 2 both work independently and preserve the
source video.

## Phase 5: User Story 3 - Extrair a faixa de áudio (Priority: P2)

**Goal**: Let an authorized user extract source audio into an M4A/AAC download
to their device without adding it to the project library or altering the source.

**Independent Test**: Extract from a video with audio and verify the authenticated
M4A/AAC download and absence of a new library item; repeat with a video without
audio and verify safe rejection and no quota use.

### Tests for User Story 3

- [ ] T037 [P] [US3] Add extraction contract tests in `projects/test/videoAudioExtract.contract.test.js` for request, M4A/AAC metadata, authenticated download, no-audio error and event shape
- [ ] T038 [P] [US3] Add extraction integration tests in `projects/test/videoAudioExtract.integration.test.js` for authorized download, no library append, source preservation, quota refund and cleanup
- [ ] T039 [P] [US3] Extend `Tools/video_audio/test_video_audio.py` with extraction to M4A/AAC, audio metadata and no-audio failure assertions

### Implementation for User Story 3

- [ ] T040 [US3] Implement extraction FFmpeg processing in `Tools/video_audio/video_audio.py` with explicit audio mapping, M4A container, AAC codec, validated metadata and no-audio failure
- [ ] T041 [US3] Extend `projects/services/videoAudioDispatcher.js` to retain the completed M4A/AAC temporarily for an authenticated download, avoid appending it to the project, and remove it after download or expiry
- [ ] T042 [US3] Extend `projects/services/videoOperationService.js` with extraction creation and no-audio precondition before quota reservation
- [ ] T043 [US3] Add `POST /:user/:project/video/:videoId/audio/extract` to `projects/routes/projects.js` and return the shared `202` operation contract
- [ ] T044 [US3] Add automatic local download after extraction and status/error presentation to `frontend/components/project-page/video-audio-dialog.tsx`; do not add extracted audio to the project list
- [ ] T045 [US3] Extend `frontend/lib/projects.ts` and the API Gateway with the authenticated audio-download stream
- [ ] T046 [US3] Run US1/US2 regression plus US3 contract, integration and worker tests; record `TST-AUD-013` through `TST-AUD-016` results

**Checkpoint**: All three user stories are independently functional and
traceable to the UC-VID-007 requirements.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verify shared security, quality, documentation and delivery
requirements across all audio operations.

- [ ] T047 [P] Add cross-project authorization tests in `projects/test/videoAudioAuthorization.integration.test.js` covering source video, operation polling, result content and WebSocket events
- [ ] T048 [P] Add quota, progress and terminal-state tests in `projects/test/videoAudioLifecycle.integration.test.js` for registered/premium profiles, `REQ-VID-Q-002`, `REQ-VID-Q-003`, failure, cancellation and no-effect operations
- [ ] T049 [P] Add cleanup tests in `projects/test/videoAudioCleanup.test.js` proving no temporary object or partial result remains after success, failure or cancellation
- [ ] T050 [P] Add frontend component/API tests for unauthorized actions, safe error messages, terminal status and result distinction in `frontend/components/project-page/video-audio-dialog.test.tsx`
- [ ] T051 Update `README.md` with audio worker startup, focused test command and the UC-VID-007 validation flow without documenting secrets or unsupported MVP features
- [ ] T052 Update `specs/007-gerir-audio/quickstart.md` with executed command output, operation IDs, result IDs and pass/fail evidence after implementation
- [ ] T053 Run `node projects/test/run-tests.js`, worker tests, frontend tests and the complete quickstart validation; fix only feature-caused failures and document known limitations
- [ ] T054 Verify every `REQ-VID-AUD-*`, referenced `REQ-VID-COM-*` and `REQ-VID-Q-*` has a component and `TST-AUD-*` result in the Phase 1 traceability evidence

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies; T001-T004 can run in parallel.
- **Foundational (Phase 2)**: depends on Setup; T005-T012 are mostly parallel,
  then T013-T014 gate all stories.
- **US1 (Phase 3)**: depends on T005-T014; this is the recommended MVP.
- **US2 (Phase 4)**: depends on foundational work and T019/T020/T023 shared
  dispatcher/service startup; it may proceed alongside US1 only if shared-file
  edits are coordinated.
- **US3 (Phase 5)**: depends on foundational work and the shared dispatcher,
  operation and storage contracts; it may proceed alongside US2 with separate
  files coordinated.
- **Polish (Phase 6)**: depends on all desired stories being complete.

### User Story Dependencies

- **US1**: independent after Foundational; no dependency on another story.
- **US2**: independent behaviorally after Foundational, but reuses the shared
  audio dispatcher/model and should integrate after its foundational pieces.
- **US3**: independent behaviorally after Foundational, but requires the private
  result path and authenticated download endpoint from Phase 2.

## Parallel Execution Examples

### Phase 1

```text
T001 Tools/video_audio files
T002 docker-compose.yaml
T003 projects/test/fixtures/videoAudioFixtures.js
T004 projects/test/run-tests.js
```

### User Story 1

```text
T015 projects/test/videoAudioRemove.contract.test.js
T016 projects/test/videoAudioRemove.integration.test.js
T017 Tools/video_audio/test_video_audio.py
```

After the tests are staged, T018, T019 and T024 can be developed in parallel
because they target the worker, backend dispatcher and frontend respectively;
T020-T023 then integrate shared service and route behavior.

### User Story 2

```text
T027 projects/test/videoAudioReplaceValidation.test.js
T028 projects/test/videoAudioReplace.integration.test.js
T029 Tools/video_audio/test_video_audio.py
```

### User Story 3

```text
T037 projects/test/videoAudioExtract.contract.test.js
T038 projects/test/videoAudioExtract.integration.test.js
T039 Tools/video_audio/test_video_audio.py
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and the blocking Phase 2.
2. Implement US1 remove audio and its tests.
3. Run the independent remove, no-audio and cancellation flows.
4. Stop for review/demo before adding replacement or extraction.

### Incremental Delivery

1. Add US2 replacement after US1 regression passes.
2. Add US3 extraction after audio-content persistence is verified.
3. Complete Phase 6 security, cleanup, documentation and traceability gates.

Every task above uses the required checklist format with a sequential ID,
`[P]` only for parallelizable work, story labels only in user-story phases,
and an explicit file path.
