#!/usr/bin/env bash
# git-guard.sh — Claude Code PreToolUse hook (matcher: Bash).
# Enforces the git-discipline rules. Reads tool-input JSON on stdin.
# exit 0 = allow; exit 2 = block (stderr shown to the model).
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)" || exit 0
[ -z "${cmd:-}" ] && exit 0

# Only git commands matter.
grep -qE '(^|[[:space:]/])git[[:space:]]' <<<"$cmd" || exit 0

deny() { printf '[git-guard] BLOCKED — %s\n' "$*" >&2; exit 2; }

# 1. No branch deletion (-d / -D / --delete).
if grep -qE 'git[[:space:]]+branch[[:space:]]+' <<<"$cmd"; then
  grep -qE '([[:space:]]|^)(-d|-D|--delete)([[:space:]]|$)' <<<"$cmd" && \
    deny '禁止删除分支（branch -d/-D/--delete）；纪律要求合并后保留分支拓扑'
fi

# 2. Merge must use --no-ff (or explicit --ff-only).
if grep -qE 'git[[:space:]]+merge[[:space:]]' <<<"$cmd"; then
  grep -qE '(--no-ff|--ff-only)' <<<"$cmd" || \
    deny 'merge 必须带 --no-ff（保留拓扑）；确需快进请显式 --ff-only'
fi

# 3. No force-adding ignored files.
if grep -qE 'git[[:space:]]+add[[:space:]]' <<<"$cmd"; then
  grep -qE '([[:space:]]|^)(-f|--force)([[:space:]]|$)' <<<"$cmd" && \
    deny '禁止 git add -f/--force（绕过 .gitignore）'
fi

# 4 & 5. Commit message hygiene.
if grep -qE 'git[[:space:]]+commit[[:space:]]' <<<"$cmd"; then
  grep -qi 'co-authored-by' <<<"$cmd" && \
    deny 'commit message 含 Co-Authored-By（纪律禁止）'
  # Best-effort: extract the -m "..." / -m '...' message.
  m="$(sed -nE "s/.*[[:space:]]-m[[:space:]]+(['\"])(.*)\1.*/\2/p" <<<"$cmd")"
  if [ -n "$m" ]; then
    grep -qE '^(feat|fix|refactor|docs|test|chore|perf|ci|build|style|revert)(\([^)]+\))?:[[:space:]].+' <<<"$m" || \
      deny "commit 不符 conventional commits（需 'type(scope?): 描述'；feat/fix/refactor/docs/test/chore/perf/ci/build/style/revert）"
  fi
fi

exit 0
