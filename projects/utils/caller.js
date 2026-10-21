const jwt = require("jsonwebtoken");

function getCallerId(req) {
  const auth = req.headers["authorization"];
  if (auth && auth.startsWith("Bearer ")) {
    const token = auth.slice("Bearer ".length);
    let payload;
    try {
      payload = jwt.verify(token, process.env.JWT_SECRET_KEY);
    } catch (_) {
      return null;
    }
    if (payload?.id) return String(payload.id);
  }
  return null;
}

module.exports = { getCallerId };
