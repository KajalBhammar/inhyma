/* ============================================================
   Image uploads — two backends, one API.

   Local / VPS  : multer writes to public/uploads/<subfolder>, and the
                  DB stores a site-relative path like
                  /uploads/products/pump-123.jpg.

   Vercel       : the filesystem is read-only (and /tmp is wiped between
                  invocations), so disk storage cannot work. When
                  BLOB_READ_WRITE_TOKEN is present we buffer the file in
                  memory, push it to Vercel Blob, and store the absolute
                  CDN URL in the DB instead.

   Call sites are unchanged either way: they still do
       uploader('products').single('image')
   and then
       webPath('products', req.file.filename)

   The trick is that in blob mode `file.filename` is already a full URL
   and webPath() passes it straight through. Templates interpolate the
   stored value into src="…", so a relative path and an absolute URL are
   equally valid there — which also means rows written before the move
   to Blob keep resolving against public/uploads/ as static assets.
   ============================================================ */
const path = require('path');
const fs = require('fs');
const multer = require('multer');

const UPLOAD_ROOT = path.join(__dirname, '..', '..', process.env.UPLOAD_DIR || 'public/uploads');

// Vercel injects this when a Blob store is linked to the project.
const BLOB_TOKEN = (process.env.BLOB_READ_WRITE_TOKEN || '').trim();
const USE_BLOB = Boolean(BLOB_TOKEN);

const MAX_MB = parseInt(process.env.MAX_UPLOAD_MB || '8', 10);
const IMAGE_MIME = /^image\/(jpe?g|png|gif|webp|svg\+xml|avif)$/;

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function fileFilter(req, file, cb) {
  const ok = IMAGE_MIME.test(file.mimetype);
  cb(ok ? null : new Error('Only image files are allowed'), ok);
}

// "Pump Station.JPEG" -> "pump-station-1720000000000.jpeg"
// basename() matches the suffix case-sensitively, so it has to be given the
// extension as originally cased — lowercasing first leaves ".JPEG" attached
// to the base and it ends up slugified into the name as "-jpeg".
function safeName(originalname) {
  const rawExt = path.extname(originalname);
  const base = path.basename(originalname, rawExt)
    .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 40);
  return `${base || 'img'}-${Date.now()}${rawExt.toLowerCase()}`;
}

function isUrl(v) {
  return typeof v === 'string' && /^https?:\/\//i.test(v);
}

/* ---------- Disk backend (local dev / long-lived server) ---------- */

function diskUploader(subfolder) {
  const dest = path.join(UPLOAD_ROOT, subfolder);
  ensureDir(dest);

  return multer({
    storage: multer.diskStorage({
      destination: (req, file, cb) => cb(null, dest),
      filename: (req, file, cb) => cb(null, safeName(file.originalname)),
    }),
    limits: { fileSize: MAX_MB * 1024 * 1024 },
    fileFilter,
  });
}

/* ---------- Blob backend (Vercel) ---------- */

// Runs after multer has buffered the upload: ships each buffer to Blob
// and rewrites file.filename to the returned public URL.
function blobPersist(subfolder) {
  return async function persist(req, res, next) {
    const files = req.files || (req.file ? [req.file] : []);
    if (!files.length) return next();

    try {
      const { put } = require('@vercel/blob');
      for (const file of files) {
        // addRandomSuffix:false keeps the name we already made unique with
        // a timestamp; without it Blob appends its own suffix and the URL
        // stops matching the filename shown in the admin UI.
        const { url } = await put(`uploads/${subfolder}/${safeName(file.originalname)}`, file.buffer, {
          access: 'public',
          contentType: file.mimetype,
          addRandomSuffix: false,
          token: BLOB_TOKEN,
        });
        file.filename = url;
        file.buffer = undefined; // let the buffer be collected promptly
      }
      next();
    } catch (err) {
      next(err);
    }
  };
}

function blobUploader(subfolder) {
  const m = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: MAX_MB * 1024 * 1024 },
    fileFilter,
  });
  const persist = blobPersist(subfolder);

  // Express flattens middleware arrays, so returning [parse, persist]
  // slots into the existing router.post(path, uploader(...).single(...), handler)
  // call sites without touching them.
  return {
    single: (field) => [m.single(field), persist],
    array: (field, max) => [m.array(field, max), persist],
    none: () => [m.none()],
  };
}

/* ---------- Public API ---------- */

function uploader(subfolder = 'misc') {
  return USE_BLOB ? blobUploader(subfolder) : diskUploader(subfolder);
}

/**
 * Turn a stored upload into the value that goes in the DB.
 * Blob mode hands us an absolute URL already; disk mode needs the
 * /uploads/<subfolder>/<name> prefix.
 */
function webPath(subfolder, filename) {
  if (!filename) return null;
  return isUrl(filename) ? filename : `/uploads/${subfolder}/${filename}`;
}

/** Delete a previously uploaded image. Best-effort — never throws. */
function removeByWebPath(webp) {
  if (!webp) return;

  if (isUrl(webp)) {
    if (!USE_BLOB) return; // not ours to delete
    try {
      const { del } = require('@vercel/blob');
      Promise.resolve(del(webp, { token: BLOB_TOKEN })).catch(() => {});
    } catch { /* @vercel/blob unavailable — nothing to clean up */ }
    return;
  }

  // Legacy disk path. On Vercel these live in the read-only deployment
  // bundle, so the unlink simply fails and the row is dropped anyway.
  const rel = webp.replace(/^\/uploads\//, '');
  fs.promises.unlink(path.join(UPLOAD_ROOT, rel)).catch(() => {});
}

module.exports = { uploader, webPath, removeByWebPath, UPLOAD_ROOT, USE_BLOB };
