import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { PGlite } from '@electric-sql/pglite';
import pg from 'pg';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const schemaPath = path.join(__dirname, '..', 'sql', 'schema.sql');
const dataDir = path.join(__dirname, '..', 'data', 'fixrwanda');

export const pool = new pg.Pool({
  connectionString:
    process.env.DATABASE_URL ||
    'postgres://fixrwanda:fixrwanda@127.0.0.1:5433/fixrwanda',
});

let pglite;

export const state = {
  postgres: false,
  engine: 'memory',
  users: [],
  categories: [],
  professionals: [],
  bookings: [],
  payments: [],
  bookingSeq: 1,
};

async function applySchema(executor) {
  const schema = fs.readFileSync(schemaPath, 'utf8');
  await executor(schema);
}

export async function initDb() {
  try {
    await pool.query('SELECT 1');
    await applySchema((sql) => pool.query(sql));
    state.postgres = true;
    state.engine = 'postgresql';
    console.log('PostgreSQL connected (TCP)');
    return;
  } catch (tcpError) {
    console.warn(`TCP PostgreSQL unavailable (${tcpError.message}).`);
  }

  try {
    fs.mkdirSync(path.dirname(dataDir), { recursive: true });
    pglite = new PGlite(dataDir);
    await pglite.waitReady;
    await applySchema((sql) => pglite.exec(sql));
    state.postgres = true;
    state.engine = 'pglite';
    console.log(`PostgreSQL engine ready (PGlite at ${dataDir})`);
  } catch (error) {
    state.postgres = false;
    state.engine = 'memory';
    console.warn(
      `PGlite unavailable (${error.message}). API is using in-memory store.`,
    );
  }
}

export async function query(text, params = []) {
  if (state.engine === 'postgresql') {
    return pool.query(text, params);
  }
  if (state.engine === 'pglite') {
    return pglite.query(text, params);
  }
  throw new Error('query() is only for PostgreSQL mode');
}
