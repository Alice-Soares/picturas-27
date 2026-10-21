function shouldReserveVideoQuota({ type }) {
  // Video frame tools run the project's standard image filters per frame;
  // they do not invoke an AI service and therefore have no daily quota.
  return false;
}

module.exports = { shouldReserveVideoQuota };
