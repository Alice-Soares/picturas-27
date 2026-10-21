const assert = require("assert");
const { canAccessProjectRoom } = require("../services/videoProjectAuthorization");

describe("video project room authorization policy", () => {
  test("requires an owner identity or a validated share permission", () => {
    assert.strictEqual(canAccessProjectRoom({ callerId: null, ownerId: "u1" }), false);
    assert.strictEqual(canAccessProjectRoom({ callerId: "u2", ownerId: "u1" }), false);
    assert.strictEqual(canAccessProjectRoom({ callerId: "u1", ownerId: "u1" }), true);
    assert.strictEqual(canAccessProjectRoom({ callerId: "u2", ownerId: "u1", sharedPermission: "read" }), true);
  });
});
