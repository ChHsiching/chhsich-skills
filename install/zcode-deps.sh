#!/usr/bin/env bash
# install/zcode-deps.sh — bootstrap chhsich-skills deps into Z.ai ZCode (Linux / macOS).
#
# Thin wrapper: clone the repo, then run the cross-platform Node installer
# (install/zcode-deps.js, driven by install/zcode-deps.json). All install logic
# lives in Node once — this just bootstraps it.
set -uo pipefail

command -v git >/dev/null || { echo "✗ git not found"; exit 1; }
command -v node >/dev/null || { echo "✗ node not found (ZCode requires Node >= 18)"; exit 1; }

REPO="https://github.com/ChHsiching/chhsich-skills.git"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "→ fetching installer…"
git clone --depth 1 "$REPO" "$TMP/repo" >/dev/null || { echo "✗ clone failed"; exit 1; }

exec node "$TMP/repo/install/zcode-deps.js"
