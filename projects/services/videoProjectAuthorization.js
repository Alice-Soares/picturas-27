function canAccessProjectRoom({ callerId, ownerId, sharedPermission }) {
  return Boolean(callerId && (String(callerId) === String(ownerId) || sharedPermission));
}

module.exports = { canAccessProjectRoom };
