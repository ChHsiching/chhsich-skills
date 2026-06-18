#!/usr/bin/env node
// git-guard.js — Claude Code / Z.ai ZCode PreToolUse hook (matcher: Bash).
// Cross-platform (Node) port of git-guard.sh — no bash, jq, grep, or sed needed,
// so it runs on Windows/macOS/Linux alike. Node is a hard dependency of both
// Claude Code and ZCode, so it is always present.
//
// Reads the tool-input JSON on stdin; exit 0 = allow, exit 2 = block
// (stderr is shown to the model).

'use strict';

const block = (msg) => {
  process.stderr.write(`[git-guard] BLOCKED — ${msg}\n`);
  process.exit(2);
};

// POSIX [[:space:]] equivalent (also matches across lines like the bash version).
const SP = '\\s';

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { raw += c; });
process.stdin.on('end', () => {
  let cmd = '';
  try {
    const input = JSON.parse(raw);
    cmd = (input && input.tool_input && input.tool_input.command) || '';
  } catch (_) { process.exit(0); }
  if (!cmd) process.exit(0);

  // Only git commands matter.
  if (!new RegExp(`(^|[${SP}/])git${SP}`).test(cmd)) process.exit(0);

  // 1. No branch deletion (-d / -D / --delete).
  if (new RegExp(`git${SP}+branch${SP}+`).test(cmd)) {
    if (new RegExp(`(^|${SP})(-d|-D|--delete)(${SP}|$)`).test(cmd))
      block('禁止删除分支（branch -d/-D/--delete）；纪律要求合并后保留分支拓扑');
  }

  // 2. Merge must use --no-ff (or explicit --ff-only).
  if (new RegExp(`git${SP}+merge${SP}+`).test(cmd)) {
    if (!/--no-ff|--ff-only/.test(cmd))
      block('merge 必须带 --no-ff（保留拓扑）；确需快进请显式 --ff-only');
  }

  // 3. No force-adding ignored files.
  if (new RegExp(`git${SP}+add${SP}+`).test(cmd)) {
    if (new RegExp(`(^|${SP})(-f|--force)(${SP}|$)`).test(cmd))
      block('禁止 git add -f/--force（绕过 .gitignore）');
  }

  // 4 & 5. Commit message hygiene.
  if (new RegExp(`git${SP}+commit${SP}+`).test(cmd)) {
    if (/co-authored-by/i.test(cmd))
      block('commit message 含 Co-Authored-By（纪律禁止）');
    // Best-effort: extract the -m "..." / -m '...' message (greedy → last -m).
    const m = cmd.match(new RegExp(`.*${SP}-m${SP}+(['"])(.*)\\1`));
    if (m) {
      const msg = m[2];
      if (!/^(feat|fix|refactor|docs|test|chore|perf|ci|build|style|revert)(\([^)]+\))?:\s.+/.test(msg))
        block(`commit 不符 conventional commits（需 'type(scope?): 描述'；feat/fix/refactor/docs/test/chore/perf/ci/build/style/revert）`);
    }
  }

  process.exit(0);
});
