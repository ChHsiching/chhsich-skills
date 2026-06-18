# ZCode Dependencies Installer — Design

**Date:** 2026-06-19 · **Status:** Approved

## Problem
chhsich-skills depends on external Claude Code plugins/skills: **ECC**, **superpowers**, **mattpocock** (`diagnosing-bugs`/`triage`/`tdd`), **karpathy** (`karpathy-guidelines`). ZCode has no third-party plugin installer, so these must be placed into ZCode's own layout for its Claude Code-compatible runtime to load. No dependency trimming — full workflow must work on ZCode.

## Approach (B — shared manifest + single Node installer)
- `install/zcode-deps.json` — single source of truth (one entry per dep).
- `install/zcode-deps.js` — cross-platform Node installer, idempotent. Core logic lives here **once**.
- `install/zcode-deps.sh` (Linux/macOS) and `install/zcode-deps.ps1` (Windows) — thin wrappers: clone the repo, then `node install/zcode-deps.js`. No duplicated install logic across shells.

## Dependency types
| type | "already installed" check | install action |
|---|---|---|
| `plugin` | `marketplaces/<m>/marketplace.json` exists **AND** `enabledPlugins[<plugin>@<m>]==true` | clone repo → `cache/<m>/<plugin>/<ver>/`; write ZCode-format marketplace.json (`source:filesystem`+`cachePath`); enable |
| `enable` | `enabledPlugins[<key>]==true` | enable only (builtin — no clone) |
| `skill` | `~/.zcode/skills/<name>` exists | clone repo (shared per repo); symlink `<subpath>` into `~/.zcode/skills/<name>` (fallback: recursive copy) |

Plugin name is **read from the repo's `.claude-plugin/plugin.json`** so `Skill("ecc:…")` / `Skill("andrej-karpathy-skills:…")` prefixes match automatically.

## Cross-platform guarantees
- Node only: `os.homedir()`, `path.join`, `fs.cpSync` (recursive), `fs.symlinkSync`. No `cp`/`ln`/`jq`.
- Windows symlink needs dev-mode/admin → falls back to `fs.cpSync` copy.
- `git clone` via `execFileSync('git', [...])` (git is a ZCode prerequisite).
- Requires Node ≥ 16.7 (for `fs.cpSync`); ZCode requires Node ≥ 18.

## Error handling
Per-dep `try/catch`; one failure does not stop the rest; end-of-run summary; exit non-zero if any failed. Re-running installs only missing deps (idempotent).

## Out of scope
- Installing chhsich-skills itself (handled by `install/zcode.sh`).
- Version pinning / upgrades (always latest `--depth 1` clone; re-run after `rm`-ing the cache to refresh).
