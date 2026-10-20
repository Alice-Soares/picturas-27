const { processWithRetry } = require("../services/videoFrameToolWorker");

describe("video frame tool failure handling", () => {
  test("retries a frame once and returns the successful attempt", async () => {
    let calls = 0;
    const attempts = await processWithRetry(async () => {
      calls += 1;
      if (calls === 1) throw new Error("temporary failure");
    });
    expect(calls).toBe(2);
    expect(attempts).toBe(2);
  });

  test("fails after the second attempt", async () => {
    let calls = 0;
    await expectAsync(processWithRetry(async () => {
      calls += 1;
      throw new Error("persistent failure");
    })).rejects("persistent failure");
    expect(calls).toBe(2);
  });
});