#!/usr/bin/env node
// Windows statusline script — no external dependencies (uses built-in https, fs, path)
const fs = require('fs');
const path = require('path');
const https = require('https');
const os = require('os');

const CLAUDE_DIR = path.join(os.homedir(), '.claude');
const CACHE_FILE = path.join(CLAUDE_DIR, 'usage-cache.json');
const CREDENTIALS_FILE = path.join(CLAUDE_DIR, '.credentials.json');
const CACHE_MAX_AGE_MS = 60 * 1000;

const CYAN = '\x1b[36m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const RED = '\x1b[31m';
const RESET = '\x1b[0m';

function makeBar(pct, filled = '▓', empty = '░', segments = 10) {
  const n = Math.round(pct / 10);
  return filled.repeat(n) + empty.repeat(segments - n);
}

function colorFor(pct, warn, danger) {
  if (pct >= danger) return RED;
  if (pct >= warn) return YELLOW;
  return GREEN;
}

function getToken() {
  try {
    const raw = fs.readFileSync(CREDENTIALS_FILE, 'utf8');
    return JSON.parse(raw)?.claudeAiOauth?.accessToken || null;
  } catch {
    return null;
  }
}

function readCache() {
  try {
    const stat = fs.statSync(CACHE_FILE);
    if (Date.now() - stat.mtimeMs < CACHE_MAX_AGE_MS) {
      return JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
    }
  } catch {}
  return null;
}

function writeCache(data) {
  try { fs.writeFileSync(CACHE_FILE, JSON.stringify(data)); } catch {}
}

function fetchUsage(token) {
  return new Promise((resolve) => {
    const req = https.request(
      {
        hostname: 'api.anthropic.com',
        path: '/api/oauth/usage',
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'anthropic-beta': 'oauth-2025-04-20',
          'Content-Type': 'application/json',
        },
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => { body += chunk; });
        res.on('end', () => {
          try {
            const json = JSON.parse(body);
            const session =
              json?.current_session?.utilization ??
              json?.session?.utilization ??
              json?.five_hour?.utilization ?? null;
            const weekly =
              json?.weekly?.utilization ??
              json?.seven_day?.utilization ?? null;
            resolve({ session, weekly });
          } catch {
            resolve(null);
          }
        });
      }
    );
    req.on('error', () => resolve(null));
    req.setTimeout(3000, () => { req.destroy(); resolve(null); });
    req.end();
  });
}

async function getUsage() {
  const cached = readCache();
  if (cached) return cached;

  const token = getToken();
  if (!token) return null;

  const data = await fetchUsage(token);
  if (data) writeCache(data);
  return data;
}

async function main() {
  let input = '';
  process.stdin.setEncoding('utf8');
  for await (const chunk of process.stdin) input += chunk;

  let json = {};
  try { json = JSON.parse(input); } catch {}

  const dir = json?.workspace?.current_dir ?? json?.cwd ?? '';
  const shortDir = path.basename(dir) || dir;
  const model = json?.model?.display_name ?? '';
  const usedPct = json?.context_window?.used_percentage ?? null;

  let status = `${CYAN}📂 ${shortDir}${RESET}`;

  if (model) {
    status += ` | ${GREEN}★ ${model}${RESET}`;
  }

  if (usedPct !== null) {
    const pct = Math.round(usedPct);
    const color = colorFor(pct, 50, 70);
    status += ` | ${color}Context: ${makeBar(pct)} ${pct}%${RESET}`;
  }

  const usage = await getUsage();
  if (usage) {
    const { session, weekly } = usage;
    const parts = [];

    if (session !== null && session !== undefined) {
      const pct = Math.round(session);
      const color = colorFor(pct, 50, 80);
      parts.push(`${color}Session: ${makeBar(pct)} ${pct}%${RESET}`);
    }

    if (weekly !== null && weekly !== undefined) {
      const pct = Math.round(weekly);
      const color = colorFor(pct, 50, 80);
      parts.push(`${color}Weekly: ${makeBar(pct)} ${pct}%${RESET}`);
    }

    if (parts.length) {
      status += ' | ' + parts.join(' | ');
    }
  }

  process.stdout.write(status + '\n');
}

main();
