#!/usr/bin/env node
// install/zcode-deps.js — install chhsich-skills' dependencies into Z.ai ZCode.
//
// Cross-platform Node installer. Idempotent (each dep installed only if missing).
// Driven by zcode-deps.json (same manifest for the sh and ps1 wrappers).
// Core logic lives HERE, once — the shell wrappers only clone this repo and run me.
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const cp = require('child_process');

const HOME = os.homedir();
const SCRIPT_DIR = __dirname;
const DEPS_JSON = path.join(SCRIPT_DIR, 'zcode-deps.json');
const PLUGINS = path.join(HOME, '.zcode', 'cli', 'plugins');
const SKILLS = path.join(HOME, '.zcode', 'skills');
const CONFIG = path.join(HOME, '.zcode', 'cli', 'config.json');
const CLONE_ROOT = path.join(PLUGINS, '_deps');

function run(cmd, args) {
  cp.execFileSync(cmd, args, { stdio: ['ignore', 'ignore', 'inherit'] });
}
function gitClone(repo, into) {
  fs.mkdirSync(path.dirname(into), { recursive: true });
  if (!fs.existsSync(into)) {
    console.log(`  cloning ${repo}`);
    run('git', ['clone', '--depth', '1', repo, into]);
  }
}
function copyDir(src, dst) {
  fs.mkdirSync(path.dirname(dst), { recursive: true });
  fs.rmSync(dst, { recursive: true, force: true });
  fs.cpSync(src, dst, { recursive: true }); // cross-platform recursive copy (Node >= 16.7)
}
function readCfg() {
  return fs.existsSync(CONFIG) ? JSON.parse(fs.readFileSync(CONFIG, 'utf8')) : {};
}
function writeCfg(c) {
  fs.mkdirSync(path.dirname(CONFIG), { recursive: true });
  fs.writeFileSync(CONFIG, JSON.stringify(c, null, 2) + '\n');
}
function cfgWithPlugins() {
  const c = readCfg();
  c.plugins = c.plugins || {};
  c.plugins.enabledPlugins = c.plugins.enabledPlugins || {};
  return c;
}
function pluginMeta(repoDir, fallbackName) {
  for (const f of ['.claude-plugin/plugin.json', '.zcode-plugin/plugin.json']) {
    const p = path.join(repoDir, f);
    if (fs.existsSync(p)) {
      const j = JSON.parse(fs.readFileSync(p, 'utf8'));
      return { name: j.name || fallbackName, version: j.version || '1.0.0' };
    }
  }
  return { name: fallbackName, version: '1.0.0' };
}
function linkOrCopy(src, dst) {
  try { fs.symlinkSync(src, dst); }       // unix; Windows with developer mode/admin
  catch (_) { copyDir(src, dst); }        // Windows fallback (or any symlink failure)
}

if (!fs.existsSync(DEPS_JSON)) {
  console.error('✗ manifest not found:', DEPS_JSON);
  process.exit(1);
}

const deps = JSON.parse(fs.readFileSync(DEPS_JSON, 'utf8')).dependencies;
const results = [];
const cloneCache = {};
function getClone(repo) {
  if (!cloneCache[repo]) {
    const slug = repo.replace(/^https?:\/\//, '').replace(/[/:]/g, '_').replace(/\.git$/, '');
    cloneCache[repo] = path.join(CLONE_ROOT, slug);
    gitClone(repo, cloneCache[repo]);
  }
  return cloneCache[repo];
}

for (const d of deps) {
  const label = d.name || d.key || d.marketplace;
  try {
    if (d.type === 'enable') {
      const c = cfgWithPlugins();
      if (c.plugins.enabledPlugins[d.key] === true) { results.push([label, '✓ enabled (skip)']); continue; }
      c.plugins.enabledPlugins[d.key] = true;
      writeCfg(c);
      results.push([label, '✓ enabled']);
    } else if (d.type === 'plugin') {
      const repoDir = getClone(d.repo);
      const meta = pluginMeta(repoDir, d.marketplace);
      const cacheDir = path.join(PLUGINS, 'cache', d.marketplace, meta.name, meta.version);
      const mktDir = path.join(PLUGINS, 'marketplaces', d.marketplace);
      const mktJson = path.join(mktDir, 'marketplace.json');
      const enKey = `${meta.name}@${d.marketplace}`;
      const c = cfgWithPlugins();
      if (fs.existsSync(mktJson) && c.plugins.enabledPlugins[enKey] === true) {
        results.push([d.marketplace, '✓ plugin (skip)']); continue;
      }
      copyDir(repoDir, cacheDir);
      fs.mkdirSync(mktDir, { recursive: true });
      fs.writeFileSync(mktJson, JSON.stringify({
        name: d.marketplace, version: 1,
        plugins: [{ name: meta.name, version: meta.version, source: 'filesystem', cachePath: cacheDir }]
      }, null, 2) + '\n');
      c.plugins.enabledPlugins[enKey] = true;
      writeCfg(c);
      results.push([d.marketplace, '✓ plugin installed']);
    } else if (d.type === 'skill') {
      const dst = path.join(SKILLS, d.name);
      if (fs.existsSync(dst)) { results.push([label, '✓ skill (skip)']); continue; }
      const repoDir = getClone(d.repo);
      const src = path.join(repoDir, d.subpath);
      if (!fs.existsSync(src)) throw new Error(`subpath not found: ${d.subpath}`);
      fs.mkdirSync(SKILLS, { recursive: true });
      linkOrCopy(src, dst);
      results.push([label, '✓ skill installed']);
    } else {
      results.push([label, '✗ unknown type: ' + d.type]);
    }
  } catch (e) {
    results.push([label, '✗ ' + (e.message || String(e))]);
  }
}

console.log('\n=== results ===');
const width = Math.max(...results.map(r => r[1].length));
for (const [n, s] of results) console.log(`  ${s.padEnd(width)}  ${n}`);
const failed = results.filter(r => r[1].includes('✗'));
if (failed.length) {
  console.error(`\n${failed.length} dependency(ies) failed.`);
  process.exit(1);
}
console.log('\nAll dependencies satisfied. Restart ZCode, then verify (skills + a bad-commit test for the hook).');
