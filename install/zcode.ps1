# install/zcode.ps1 — install chhsich-skills into Z.ai ZCode (Windows).
#
# ZCode has no built-in third-party plugin installer. This mirrors ZCode's OWN
# plugin layout so it picks the plugin up at startup:
#   - skills  → %USERPROFILE%\.zcode\skills\<name>          (ZCode scans this — reliable)
#   - plugin  → %USERPROFILE%\.zcode\cli\plugins\cache\...   (marketplace.json + enabledPlugins)
$ErrorActionPreference = 'Stop'

$Repo   = 'https://github.com/ChHsiching/chhsich-skills.git'
$Name   = 'chhsich-skills'
$Ver    = '1.0.0'
$Skills = 'bugfix-discipline','ecc-subagent-invocation','git-discipline','parallel-issue-execution'

$Home0       = $env:USERPROFILE
$ZcodeSkills = Join-Path $Home0 '.zcode\skills'
$CacheDir    = Join-Path $Home0 ".zcode\cli\plugins\cache\$Name\$Name\$Ver"
$MktDir      = Join-Path $Home0 ".zcode\cli\plugins\marketplaces\$Name"
$Config      = Join-Path $Home0 '.zcode\cli\config.json'

foreach ($t in 'git','node') {
  if (-not (Get-Command $t -ErrorAction SilentlyContinue)) { throw "$t not found (ZCode requires it)" }
}

Write-Host "-> cloning $Name into ZCode plugin cache..."
New-Item -ItemType Directory -Force -Path (Split-Path $CacheDir) | Out-Null
if (Test-Path $CacheDir) { Remove-Item -Recurse -Force $CacheDir }
& git clone --depth 1 $Repo $CacheDir 2>$null
if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

Write-Host "-> copying skills into $ZcodeSkills ..."
New-Item -ItemType Directory -Force -Path $ZcodeSkills | Out-Null
foreach ($s in $Skills) {
  $dst = Join-Path $ZcodeSkills $s
  if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
  Copy-Item -Recurse (Join-Path $CacheDir "skills\$s") $dst
}

Write-Host "-> registering ZCode marketplace..."
New-Item -ItemType Directory -Force -Path $MktDir | Out-Null
$mkt = [ordered]@{
  name = $Name
  version = 1
  plugins = @(
    [ordered]@{ name = $Name; version = $Ver; source = 'filesystem'; cachePath = $CacheDir }
  )
}
$mkt | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 (Join-Path $MktDir 'marketplace.json')

Write-Host "-> enabling plugin in $Config ..."
# node merges the JSON reliably (cross-platform), avoids PSObject nested-add friction
$merge = "const fs=require('fs'),p=process.argv[1];const c=fs.existsSync(p)?JSON.parse(fs.readFileSync(p,'utf8')):{};c.plugins=c.plugins||{};c.plugins.enabledPlugins=c.plugins.enabledPlugins||{};c.plugins.enabledPlugins['chhsich-skills@chhsich-skills']=true;fs.writeFileSync(p,JSON.stringify(c,null,2)+'\n');"
& node -e $merge $Config

Write-Host ""
Write-Host "* Done. Restart ZCode, then verify:"
Write-Host "  * skills - ask the agent to use bugfix-discipline / git-discipline / etc."
Write-Host "  * hook   - try a bad commit, e.g.  git commit -m bad  -> git-guard.js should block it."
Write-Host "  * logs   - %USERPROFILE%\.zcode\cli\log\"
Write-Host ""
Write-Host "Note: ZCode has no official third-party plugin installer; this mirrors its"
Write-Host "built-in plugin layout. Skills load reliably; the hook depends on ZCode"
Write-Host "resolving the marketplace - verify after restart."
