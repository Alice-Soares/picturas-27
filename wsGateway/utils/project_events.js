function emitProjectOperation(io, message) {
  const projectId = message?.projectId;
  const operation = message?.op;
  if (!projectId || !operation) return false;
  io.to(`project:${projectId}`).emit("project-op", { projectId, op: operation });
  return true;
}

module.exports = { emitProjectOperation };