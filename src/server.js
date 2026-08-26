/* ============================================================
   INHYMA Website — Express server entry
   ============================================================ */
require('dotenv').config();
const path = require('path');
const express = require('express');
const compression = require('compression');
const cookieSession = require('cookie-session');
const flash = require('connect-flash');
const nunjucks = require('nunjucks');

const { exposeLocals } = require('./middleware/auth');
const publicRoutes = require('./routes/public');
const adminRoutes = require('./routes/admin');
const apiRoutes = require('./routes/api');

const app = express();
const ROOT = path.join(__dirname, '..');

// Vercel sets VERCEL=1 in both the build and the runtime.
const ON_VERCEL = Boolean(process.env.VERCEL);
const IS_PROD = ON_VERCEL || process.env.NODE_ENV === 'production';

// Vercel terminates TLS at the edge and forwards over HTTP, so without
// this req.secure is false and secure cookies would never be set.
if (ON_VERCEL) app.set('trust proxy', 1);

/* ---------- Compression middleware ---------- */
app.use(compression());

/* ---------- Request timing (visible in server logs) ---------- */
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - start;
    if (ms > 100) console.log(`⏱ ${req.method} ${req.originalUrl} — ${ms}ms`);
  });
  next();
});

/* ---------- View engine (Nunjucks / Jinja-style) ---------- */
const env = nunjucks.configure(path.join(ROOT, 'views'), {
  autoescape: true,
  express: app,
  watch: !IS_PROD, // file watching is pointless (and unsupported) on a read-only FS
});
app.set('view engine', 'njk');

// Template filters
env.addFilter('date', (d, fmt) => {
  if (!d) return '';
  const dt = new Date(d);
  const opts = { year: 'numeric', month: 'long', day: '2-digit' };
  return dt.toLocaleDateString('en-US', opts);
});
env.addFilter('isodate', (d) => {
  if (!d) return '';
  const dt = new Date(d);
  if (isNaN(dt)) return '';
  return dt.toISOString().slice(0, 10);
});
env.addFilter('truncate', (s, n) => {
  if (!s) return '';
  return s.length > n ? s.slice(0, n).trim() + '…' : s;
});

/* ---------- Body parsing & static ---------- */
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(ROOT, 'public'), {
  maxAge: '1d', // Cache static assets for 1 day
  etag: true,
}));

/* ---------- Sessions & flash ----------
   Cookie-backed rather than server-backed. express-session's default
   MemoryStore is per-process, and on Vercel every request may hit a
   different (or freshly cold-started) instance, so a login would not
   survive the redirect off the login form. Keeping the session in a
   signed cookie makes it stateless, which is the only thing that holds
   across instances without adding another connection to the DB.

   Tradeoff: sessions can no longer be revoked server-side, and the
   payload must stay under ~4KB. We store {id, username, name, role}
   plus flash messages, so there is a lot of headroom.
   ---------------------------------------------------------------- */
app.use(cookieSession({
  name: 'inhyma.sid',
  keys: [process.env.SESSION_SECRET || 'inhyma-dev-secret'],
  maxAge: 1000 * 60 * 60 * 8, // 8h
  httpOnly: true,
  sameSite: 'lax',
  secure: IS_PROD,
}));

// express-session compatibility: routes call req.session.destroy(cb) on
// logout. Defined non-enumerably so it is never serialised into the cookie.
app.use((req, res, next) => {
  if (req.session && typeof req.session.destroy !== 'function') {
    Object.defineProperty(req.session, 'destroy', {
      value: (cb) => { req.session = null; if (typeof cb === 'function') cb(); },
      enumerable: false,
      configurable: true,
    });
  }
  next();
});

app.use(flash());
app.use(exposeLocals);

/* ---------- Routes ---------- */
app.use('/admin', adminRoutes);
app.use('/api', apiRoutes);
app.use('/', publicRoutes);

/* ---------- 404 ---------- */
app.use((req, res) => {
  res.status(404).render('public/404', { title: 'Page Not Found' });
});

/* ---------- Error handler ---------- */
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500);
  if (req.path.startsWith('/admin')) {
    req.flash && req.flash('error', err.message || 'Something went wrong');
    return res.redirect('back');
  }
  res.render('public/error', { title: 'Error', message: process.env.NODE_ENV === 'production' ? 'Something went wrong.' : err.message });
});

const PORT = parseInt(process.env.PORT, 10) || 5000;
const MAX_PORT_TRIES = 10;

function startServer(port, attempt = 0) {
  const server = app.listen(port, () => {
    const os = require('os');
    const nets = os.networkInterfaces();
    let networkIp = 'localhost';
    for (const name of Object.keys(nets)) {
      for (const net of nets[name]) {
        if (net.family === 'IPv4' && !net.internal) {
          networkIp = net.address;
        }
      }
    }
    
    console.log(`\n🚀 INHYMA site running:`);
    console.log(`   - Local:    http://localhost:${port}`);
    console.log(`   - Network:  http://${networkIp}:${port}`);
    console.log(`🔐 Admin panel:   http://localhost:${port}/admin\n`);
  });
  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE' && attempt < MAX_PORT_TRIES) {
      const next = port + 1;
      console.warn(`⚠ Port ${port} is in use — trying ${next}...`);
      startServer(next, attempt + 1);
    } else {
      console.error('❌ Failed to start server:', err.message);
      process.exit(1);
    }
  });
}

/* ------------------------------------------------------------
   Vercel runs this file as a Node server and routes traffic to
   whatever port we bind, so listen() is unconditional. Only the
   pre-warm stays local-only: on Vercel it would add four blocking
   round-trips to the very first request it was meant to speed up.
   ------------------------------------------------------------ */
startServer(PORT);

if (!ON_VERCEL) {
  // Pre-warm DB pool + caches on startup so first request is instant
  (async () => {
    try {
      const { getPool } = require('./db');
      await getPool(); // open connection pool ahead of time
      const { loadSettings, cache } = require('./utils/helpers');
      const { query } = require('./db');
      await loadSettings(); // pre-cache settings
      cache.navCategories = await query('usp_Category_Manage', { Action: 'GET_ALL', IncludeInactive: 0 });
      cache.navSubcategories = await query('usp_Subcategory_Manage', { Action: 'GET_ALL', IncludeInactive: 0 });
      cache.navIndustries = await query('usp_Industry_Manage', { Action: 'GET_ALL', IncludeInactive: 0 });
      console.log('✓ Caches pre-warmed (settings, categories, subcategories, industries)');
    } catch (e) {
      console.warn('⚠ Cache pre-warm failed (will lazy-load):', e.message);
    }
  })();
}

module.exports = app;
