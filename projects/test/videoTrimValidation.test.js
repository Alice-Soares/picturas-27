const { validateTrimInterval } = require("../services/videoTrimValidation");

describe("video trim interval", () => {
  test("accepts a one-second interval at the boundaries", () => {
    expect(validateTrimInterval({ startSeconds: 0, endSeconds: 1, duration: 10 })).toEqual({
      startSeconds: 0,
      endSeconds: 1,
      durationSeconds: 1,
    });
  });

  for (const [startSeconds, endSeconds, duration, code] of [
    [-1, 2, 10, "VIDEO_TRIM_INVALID_START"],
    [1, 11, 10, "VIDEO_TRIM_INVALID_END"],
    [2, 2, 10, "VIDEO_TRIM_INVALID_INTERVAL"],
    [2, 1, 10, "VIDEO_TRIM_INVALID_INTERVAL"],
    [0, 0.5, 10, "VIDEO_TRIM_TOO_SHORT"],
  ]) test(`rejects invalid interval ${startSeconds}/${endSeconds}`, () => {
    expect(() => validateTrimInterval({ startSeconds, endSeconds, duration })).toThrow(code);
  });
});
