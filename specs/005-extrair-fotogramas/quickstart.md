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
5. Cancel during processing; confirm `cancelled`, quota refund, no public
   partial images and cleanup of temporary objects.
6. Force a worker/storage failure after at least one upload; confirm `failed`,
   public error, cleanup and unchanged source-video hash.
7. Query the operation from an unrelated project/user; confirm `404`/`403` and
   no event or result disclosure.

Record profile, project ID, operation ID, state transitions, extracted count,
resulting image keys and pass/fail evidence for each scenario.

## Current validation evidence

- Backend syntax checks: passed.
- Projects test runner: 24 tests passed.
- Frontend `npm run lint`: passed with existing hook/image warnings and one
  analogous warning in the new polling dialog.
- Frontend `npm run build`: passed; font download retries occurred because the
  build environment could not reach Google Fonts.
- Docker end-to-end execution: not run in this implementation pass.
