# install/zcode-deps.ps1 — bootstrap chhsich-skills deps into Z.ai ZCode (Windows).
#
# Thin wrapper: clone the repo, then run the cross-platform Node installer
# (install/zcode-deps.js, driven by install/zcode-deps.json). All install logic
# lives in Node once — this just bootstraps it.
$ErrorActionPreference = 'Stop'

foreach ($t in 'git','node') {
  if (-not (Get-Command $t -ErrorAction SilentlyContinue)) {
    throw "$t not found (ZCode requires Node >= 18)"
  }
}

$Repo = 'https://github.com/ChHsiching/chhsich-skills.git'
$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("chhsich-deps-" + [guid]::NewGuid().ToString('n'))
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null

try {
  Write-Host "-> fetching installer..."
  & git clone --depth 1 $Repo (Join-Path $Tmp 'repo') 2>$null
  if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
  & node (Join-Path $Tmp 'repo\install\zcode-deps.js')
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
  Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue
}
