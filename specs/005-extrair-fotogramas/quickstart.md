# Quickstart: UC-VID-005

## Automated checks

From the repository root:

```bash
node projects/test/run-tests.js
cd frontend && npm run build
```

Expected backend result: all existing video tests plus
`videoFrameExtractionValidation.test.js` pass. The frontend build must compile
and pass TypeScript validation; existing lint warnings may remain.

## Manual scenarios

1. Select a valid video as a registered user, configure interval and maximum,
   submit, observe `queued`/`processing`, and confirm JPEGs in the project.
2. Repeat with a premium user and maximum 5000.
3. Try an interval outside duration, zero/negative maximum, PNG format and the
   registered limit; confirm no operation is queued.
4. Try a project/video without authorization; confirm rejection without
   metadata disclosure.
5. Cancel during processing; confirm `cancelled`, no quota consumption, no public
   partial images and cleanup of temporary objects.
6. Force a worker/storage failure after at least one upload; confirm `failed`,
   public error, cleanup and unchanged source-video hash.
7. Query the operation from an unrelated project/user; confirm `404`/`403` and
   no event or result disclosure.

Record profile, project ID, operation ID, state transitions, extracted count,
resulting image keys and pass/fail evidence for each scenario.

## Current validation evidence

- `docker compose config -q`: passed on 2026-10-21.
- `docker compose run --rm --no-deps projects node test/run-tests.js`: 36 tests
  passed, including the extraction validation tests.
- `npx tsc --noEmit`: passed; Docker frontend production build passed with
  existing hook/image lint warnings.
- Docker smoke scenario for the baseline image tool list: add, delete, then
  fetch the project and confirm the tool is absent. Temporary account/project
  were deleted after the scenario.
- The video extraction end-to-end scenarios below were not run. UC-VID-005
  acceptance remains pending; this smoke scenario is not evidence for frame
  extraction, quota non-consumption, cancellation, storage cleanup or project destination.
