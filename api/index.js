/* ============================================================
   Vercel serverless entry point.

   @vercel/node treats a default export that looks like (req, res) as
   the handler, and an Express app is exactly that — so the whole site
   runs as one function. src/server.js skips app.listen() when VERCEL
   is set, leaving the platform to own the HTTP server.
   ============================================================ */
module.exports = require('../src/server');
