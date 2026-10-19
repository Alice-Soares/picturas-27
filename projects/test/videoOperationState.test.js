const { assertTransition, canTransition } = require("../services/videoOperationState");

describe("video operation states", () => {
  test("allows the supported lifecycle", () => {
    expect(canTransition("queued", "processing")).toBe(true);
    expect(canTransition("processing", "completed")).toBe(true);
    expect(canTransition("processing", "cancelled")).toBe(true);
  });

  test("rejects transitions from terminal states", () => {
    expect(() => assertTransition("completed", "cancelled")).toThrow();
    expect(() => assertTransition("queued", "completed")).toThrow();
  });
});
