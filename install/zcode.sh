#!/usr/bin/env bash
# install/zcode.sh — install chhsich-skills into Z.ai ZCode.
#
# ZCode has no built-in third-party plugin installer (no /plugin command, no
# marketplace GUI). This script mirrors ZCode's OWN plugin layout so it picks
# the plugin up at startup:
#   - skills  → ~/.zcode/skills/<name>          (ZCode scans this — reliable)
#   - plugin  → ~/.zcode/cli/plugins/cache/...  (marketplace.json + enabledPlugins,
#                same shape as ZCode's bundled plugins, so the git-discipline
#                PreToolUse hook loads too)
set -euo pipefail

REPO="https://github.com/ChHsiching/chhsich-skills.git"
NAME="chhsich-skills"
VER="1.0.0"
SKILLS=(bugfix-discipline ecc-subagent-invocation git-discipline parallel-issue-execution)

ZCODE_SKILLS="${HOME}/.zcode/skills"
CACHE_DIR="${HOME}/.zcode/cli/plugins/cache/${NAME}/${NAME}/${VER}"
MKT_DIR="${HOME}/.zcode/cli/plugins/marketplaces/${NAME}"
CONFIG="${HOME}/.zcode/cli/config.json"

command -v git >/dev/null || { echo "git not found"; exit 1; }
command -v node >/dev/null || { echo "node not found (ZCode requires it)"; exit 1; }

echo "→ cloning ${NAME} into ZCode plugin cache…"
mkdir -p "$(dirname "$CACHE_DIR")"
rm -rf "$CACHE_DIR"
git clone --depth 1 "$REPO" "$CACHE_DIR" >/dev/null

echo "→ linking skills into ${ZCODE_SKILLS}/ …"
mkdir -p "$ZCODE_SKILLS"
for s in "${SKILLS[@]}"; do
  ln -sfn "$CACHE_DIR/skills/$s" "$ZCODE_SKILLS/$s"
done

echo "→ registering ZCode marketplace (filesystem source, like bundled plugins)…"
mkdir -p "$MKT_DIR"
cat > "$MKT_DIR/marketplace.json" <<JSON
{
  "name": "${NAME}",
  "version": 1,
  "plugins": [
    { "name": "${NAME}", "version": "${VER}", "source": "filesystem", "cachePath": "${CACHE_DIR}" }
  ]
}
JSON

echo "→ enabling plugin in ${CONFIG} …"
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const cfg = fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, "utf8")) : {};
  cfg.plugins = cfg.plugins || {};
  cfg.plugins.enabledPlugins = cfg.plugins.enabledPlugins || {};
  cfg.plugins.enabledPlugins["chhsich-skills@chhsich-skills"] = true;
  fs.writeFileSync(p, JSON.stringify(cfg, null, 2) + "\n");
' "$CONFIG"

cat <<EOF

✓ Done. Restart ZCode, then verify:
  • skills — ask the agent to use bugfix-discipline / git-discipline / etc.
  • hook   — try a bad commit, e.g.  git commit -m "bad"  → git-guard.js should block it.
  • logs   — ~/.zcode/cli/log/  (pluginCount / hookCount should rise).

Note: ZCode has no official third-party plugin installer; this mirrors its
built-in plugin layout. Skills load reliably; the hook depends on ZCode
resolving the marketplace — verify after restart and report back if not.
EOF
