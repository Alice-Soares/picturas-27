const assert = require("assert");

function canSubmit({ callerId, ownerId, projectExists }) {
  return Boolean(callerId && projectExists && String(callerId) === String(ownerId));
}

assert.strictEqual(canSubmit({ callerId: null, ownerId: "u1", projectExists: true }), false);
assert.strictEqual(canSubmit({ callerId: "u2", ownerId: "u1", projectExists: true }), false);
assert.strictEqual(canSubmit({ callerId: "u1", ownerId: "u1", projectExists: true }), true);
