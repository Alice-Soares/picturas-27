const { shouldReserveVideoQuota } = require("../services/videoQuotaPolicy");

test("all audio operations are unlimited because they do not use AI", () => {
  for (const action of ["remove", "replace", "extract"]) {
    expect(shouldReserveVideoQuota({ type: "audio", purpose: "user", action })).toBe(false);
  }
  expect(shouldReserveVideoQuota({ type: "audio", purpose: "playback" })).toBe(false);
});

test("frame extraction uses its profile frame limit without daily advanced quota", () => {
  expect(shouldReserveVideoQuota({ type: "frame_extract" })).toBe(false);
});

test("only AI frame tools use the daily advanced quota", () => {
  expect(shouldReserveVideoQuota({ type: "frame_tool" })).toBe(true);
  for (const type of ["trim", "conversion", "audio", "frame_extract", "merge", "unknown"]) {
    expect(shouldReserveVideoQuota({ type })).toBe(false);
  }
});
