const transitions = {
  queued: new Set(["processing", "failed", "cancelled"]),
  processing: new Set(["completed", "failed", "cancelled"]),
  completed: new Set(),
  failed: new Set(),
  cancelled: new Set(),
};

function canTransition(from, to) {
  return from === to || transitions[from]?.has(to) === true;
}

function assertTransition(from, to) {
  if (!canTransition(from, to)) {
    throw new Error(`VIDEO_OPERATION_INVALID_TRANSITION:${from}:${to}`);
  }
}

module.exports = { canTransition, assertTransition, transitions };
