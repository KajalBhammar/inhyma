/* ============================================================
   Database layer — MySQL via mysql2
   ALL access goes through stored procedures. No raw queries.

   Migrated from SQL Server. Two things differ from the old mssql
   layer, and both are handled here so route code stays unchanged:

   1. mssql bound parameters BY NAME; MySQL only accepts them
      POSITIONALLY. execProc() therefore looks up each procedure's
      real parameter order from information_schema at startup and
      maps { Action: 'GET_ALL', Search: 'x' } onto CALL usp_X(?,?,...).
      Anything not supplied is passed as NULL, which is exactly what
      omitting an argument meant in SQL Server.

   2. mysql2 appends an OK packet to every CALL result. shapeResult()
      strips it and re-exposes the mssql shape ({ recordset,
      recordsets, rowsAffected }) the routes already expect.
   ============================================================ */
const mysql = require('mysql2/promise');

/* ------------------------------------------------------------
   Type shim.

   Route code writes things like
       { type: sql.Int, value: null }
       { type: sql.NVarChar(sql.MAX), value: html }
   which was how the mssql driver was told a column's type. MySQL
   infers types from the JS value, so the tags are inert — but the
   shim keeps every existing call site compiling untouched.
   ------------------------------------------------------------ */
const MAX = 'max';
function NVarChar(len) { return { t: 'nvarchar', len }; }
const sql = {
  Int: { t: 'int' },
  BigInt: { t: 'bigint' },
  Bit: { t: 'bit' },
  Date: { t: 'date' },
  DateTime: { t: 'datetime' },
  DateTime2: { t: 'datetime2' },
  Decimal: { t: 'decimal' },
  Text: { t: 'text' },
  NVarChar,
  VarChar: NVarChar,
  MAX,
};

/* ------------------------------------------------------------
   Connection config

   Prefers a single connection URL (DATABASE_URL), which is what
   hosted providers hand you:
     mysql://user:pass@host:port/dbname?ssl-mode=REQUIRED
   Falls back to discrete DB_* variables.
   ------------------------------------------------------------ */
function buildConfig() {
  const url = (process.env.DATABASE_URL || process.env.MYSQL_URL || '').trim();

  let host, port, user, password, database, sslRequired;

  if (url) {
    const u = new URL(url);
    host = decodeURIComponent(u.hostname);
    port = parseInt(u.port, 10) || 3306;
    user = decodeURIComponent(u.username);
    password = decodeURIComponent(u.password);
    database = decodeURIComponent(u.pathname.replace(/^\//, ''));
    const mode = (u.searchParams.get('ssl-mode') || u.searchParams.get('sslmode') || '').toUpperCase();
    sslRequired = mode === 'REQUIRED' || mode === 'VERIFY_CA' || mode === 'VERIFY_IDENTITY';
  } else {
    host = (process.env.DB_HOST || process.env.DB_SERVER || 'localhost').trim();
    port = parseInt(process.env.DB_PORT, 10) || 3306;
    user = process.env.DB_USERNAME;
    password = process.env.DB_PASSWORD;
    database = process.env.DB_DATABASE;
    sslRequired = String(process.env.DB_SSL).toLowerCase() === 'true';
  }

  const config = {
    host,
    port,
    user,
    password,
    database,
    charset: 'utf8mb4_unicode_ci',

    // Serialise/parse DATETIME as UTC. The stored procedures compare
    // against UTC_TIMESTAMP(), so a local-time Date would be wrong by
    // the server's offset (5h30m here) and break lead reminders.
    timezone: 'Z',

    waitForConnections: true,
    connectionLimit: parseInt(process.env.DB_POOL_MAX, 10) || 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 10000,
  };

  // ssl-mode=REQUIRED means "encrypt, but don't verify the CA" — the
  // direct equivalent of rejectUnauthorized:false. To verify properly,
  // download the provider's CA and set DB_SSL_CA to its path.
  if (sslRequired) {
    const caPath = (process.env.DB_SSL_CA || '').trim();
    if (caPath) {
      config.ssl = { ca: require('fs').readFileSync(caPath, 'utf8'), rejectUnauthorized: true };
    } else {
      config.ssl = { rejectUnauthorized: false };
    }
  }

  return config;
}

let rawPool = null;
let rawCfg = null;
let poolPromise = null;
let procParams = null; // Map<procName, ['Action','ProductId',...]>

/**
 * Read each procedure's real parameter order out of the database.
 * Doing this at runtime rather than hardcoding a list means the map
 * can never drift out of sync with 02_procedures_mysql.sql.
 */
async function loadProcedureParams(pool) {
  const map = new Map();

  // Seed from ROUTINES first. A procedure that takes no arguments —
  // usp_Dashboard_Counts — has no rows at all in PARAMETERS, so building
  // the map from PARAMETERS alone would leave it unregistered and every
  // call to it would fail as "unknown stored procedure".
  const [procs] = await pool.query(
    `SELECT ROUTINE_NAME
       FROM information_schema.ROUTINES
      WHERE ROUTINE_SCHEMA = DATABASE()
        AND ROUTINE_TYPE = 'PROCEDURE'`
  );
  for (const p of procs) map.set(p.ROUTINE_NAME, []);

  const [rows] = await pool.query(
    `SELECT SPECIFIC_NAME, PARAMETER_NAME, ORDINAL_POSITION
       FROM information_schema.PARAMETERS
      WHERE SPECIFIC_SCHEMA = DATABASE()
        AND ROUTINE_TYPE = 'PROCEDURE'
        AND PARAMETER_NAME IS NOT NULL
      ORDER BY SPECIFIC_NAME, ORDINAL_POSITION`
  );
  for (const r of rows) {
    if (!map.has(r.SPECIFIC_NAME)) map.set(r.SPECIFIC_NAME, []);
    // Strip the p_ prefix the procedures use to avoid column-name clashes,
    // so routes keep passing { Action, ProductId, ... }.
    map.get(r.SPECIFIC_NAME).push(String(r.PARAMETER_NAME).replace(/^p_/i, ''));
  }
  return map;
}

/**
 * The mysql2 pool itself — created synchronously and lazily.
 *
 * mysql2's createPool() opens no sockets; connections are dialled on
 * first use. That is what lets the session store take this pool at
 * middleware-setup time (which cannot await) instead of opening a
 * second one of its own. On serverless every extra pool is another
 * slot spent against the provider's connection cap, which is why the
 * whole process shares exactly one.
 */
function getRawPool() {
  if (!rawPool) {
    rawCfg = buildConfig();
    rawPool = mysql.createPool(rawCfg);
  }
  return rawPool;
}

function getPool() {
  if (!poolPromise) {
    poolPromise = (async () => {
      const pool = getRawPool();
      await pool.query('SELECT 1');            // fail fast on bad credentials
      procParams = await loadProcedureParams(pool);
      console.log(`✓ Connected to MySQL: ${rawCfg.database} @ ${rawCfg.host}:${rawCfg.port}` +
                  ` (${procParams.size} procedures)`);
      return pool;
    })().catch((err) => {
      poolPromise = null;                      // allow retry on next call
      throw err;
    });
  }
  return poolPromise;
}

/** Unwrap the { type, value } tags the old mssql call sites use. */
function unwrap(v) {
  if (v === undefined) return null;            // mysql2 rejects undefined
  if (v !== null && typeof v === 'object' && !(v instanceof Date) && 'value' in v) {
    return v.value === undefined ? null : v.value;
  }
  return v;
}

/**
 * Re-shape a mysql2 CALL result into the mssql result object the
 * routes already destructure.
 *
 * mysql2 returns an array of result sets with a trailing OK packet,
 * or a bare OK packet when the procedure SELECTed nothing.
 */
function shapeResult(raw) {
  const recordsets = [];
  const rowsAffected = [];

  const consume = (item) => {
    if (Array.isArray(item)) recordsets.push(item);
    else if (item && typeof item === 'object' && 'affectedRows' in item) rowsAffected.push(item.affectedRows);
  };

  if (Array.isArray(raw)) raw.forEach(consume);
  else consume(raw);

  return {
    recordset: recordsets[0] || [],
    recordsets,
    rowsAffected,
    output: {},
  };
}

/**
 * Execute a stored procedure.
 * @param {string} procName  e.g. 'usp_Product_Manage'
 * @param {Object} params    { Action: 'GET_ALL', Search: 'pump' }
 *                           values may be raw, or { type, value }
 * @returns {Promise<{recordset, recordsets, rowsAffected, output}>}
 */
async function execProc(procName, params = {}) {
  const pool = await getPool();

  const order = procParams.get(procName);
  if (!order) {
    throw new Error(
      `Unknown stored procedure "${procName}". Known: ${[...procParams.keys()].join(', ')}`
    );
  }

  // Index the supplied values case-insensitively.
  const supplied = new Map();
  for (const [key, val] of Object.entries(params)) {
    supplied.set(key.toLowerCase(), unwrap(val));
  }

  // A name that matches no parameter is a bug, not something to ignore
  // silently — it would send the wrong query and look like a data issue.
  const known = new Set(order.map((n) => n.toLowerCase()));
  for (const key of supplied.keys()) {
    if (!known.has(key)) {
      throw new Error(`"${procName}" has no parameter "${key}". Expected: ${order.join(', ')}`);
    }
  }

  const values = order.map((name) => {
    const key = name.toLowerCase();
    return supplied.has(key) ? supplied.get(key) : null;
  });

  const placeholders = order.map(() => '?').join(', ');
  const [raw] = await pool.query(`CALL \`${procName}\`(${placeholders})`, values);
  return shapeResult(raw);
}

/** Convenience: return first recordset rows. */
async function query(procName, params = {}) {
  const result = await execProc(procName, params);
  return result.recordset || [];
}

/** Convenience: return first row of first recordset (or null). */
async function queryOne(procName, params = {}) {
  const rows = await query(procName, params);
  return rows[0] || null;
}

/** Close the pool (tests / graceful shutdown). */
async function closePool() {
  if (!rawPool) return;
  const pool = rawPool;
  rawPool = null;
  rawCfg = null;
  poolPromise = null;
  procParams = null;
  await pool.end();
}

module.exports = { sql, getPool, getRawPool, execProc, query, queryOne, closePool };
