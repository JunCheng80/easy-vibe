# build_2026S3.ps1
# ------------------------------------------------------------
# Modes:
#   full  : Step C + MD + DOCX(weekly+merge) + publish to docs
#   md    : Step C + MD only + publish md
#   docx  : Step C + DOCX weekly only (no merge) + publish weekly (optional)
#   merge : Merge only (merge existing _weeks_tmp) + publish merged
#
# Run examples:
#   powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\build_2026S3.ps1 full
#   powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\build_2026S3.ps1 docx
#   powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\build_2026S3.ps1 merge
# ------------------------------------------------------------

$ErrorActionPreference = "Stop"

# ---------- mode ----------
$MODE = "full"
if ($args.Count -ge 1 -and -not [string]::IsNullOrWhiteSpace($args[0])) {
  $MODE = $args[0].ToLower()
}
if (@("full","md","docx","merge") -notcontains $MODE) {
  throw "Invalid MODE: $MODE. Use: full | md | docx | merge"
}

# ---------- repo root ----------
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

function Ensure-Dir([string]$p) {
  if ([string]::IsNullOrWhiteSpace($p)) { throw "Ensure-Dir: path is empty." }
  New-Item -ItemType Directory -Force -Path $p | Out-Null
}

function Assert-File([string]$p, [string]$hint) {
  if ([string]::IsNullOrWhiteSpace($p)) { throw "Path is empty. Hint: $hint" }
  if (!(Test-Path $p)) { throw "Missing: $p`nHint: $hint" }
}

function Week-Ids { 1..16 | ForEach-Object { "week{0:d2}" -f $_ } }

# ---------- config ----------
$courseSlug = "speech_appdev"
$termSlug   = "2026S3"
$runStamp   = (Get-Date -Format "yyyyMMdd")

# publish switches
$publishWeeklyDocxToSite = $true   # set $false if you don't want _weeks_tmp in docs

Write-Host "MODE=$MODE"
Write-Host "repoRoot=$repoRoot"
Write-Host "course=$courseSlug term=$termSlug runStamp=$runStamp"

# ---------- inputs ----------
$courseYaml = Join-Path $repoRoot "lesson-builder\00-input\courses\$courseSlug.dl.yaml"
$specRoot   = Join-Path $repoRoot "lesson-builder\00-input\lesson_specs\$courseSlug"
$yamlDir    = Join-Path $specRoot "yaml"

$week01Source = Join-Path $specRoot "week01.yaml"
$week01Target = Join-Path $yamlDir  "week01.yaml"
$genWeeksScript = Join-Path $specRoot "gen_weeks_02_16.ps1"

# ---------- engines ----------
$engineMd = Join-Path $repoRoot "lesson-builder\10-engine\gen_lesson_plan.mjs"
$renderPy = Join-Path $repoRoot "lesson-builder\10-engine\render_lesson_plans_docx.py"

# templates (only for preflight)
$tplCover = Join-Path $repoRoot "lesson-builder\20-templates\kmcc_lesson_plan_master.docx"
$tplBody  = Join-Path $repoRoot "lesson-builder\20-templates\kmcc_lesson_plan_body.docx"

# ---------- outputs factory ----------
$outLatestRoot   = Join-Path $repoRoot "lesson-builder\30-outputs\$courseSlug\$termSlug"
$outLatestMdDir  = Join-Path $outLatestRoot "md"
$outLatestDocDir = Join-Path $outLatestRoot "docx"

$outRunRoot   = Join-Path $repoRoot "lesson-builder\30-outputs\$courseSlug\$termSlug\$runStamp"
$outRunMdDir  = Join-Path $outRunRoot "md"
$outRunDocDir = Join-Path $outRunRoot "docx"
$outRunLogDir = Join-Path $outRunRoot "_logs"

# ---------- outputs site (stable) ----------
$siteRoot   = Join-Path $repoRoot "docs\zh-cn\lesson-plans\$courseSlug\$termSlug"
$siteMdDir  = Join-Path $siteRoot "md"
$siteDocDir = Join-Path $siteRoot "docx"

# ---------- dirs ----------
Ensure-Dir $yamlDir
Ensure-Dir $outLatestMdDir
Ensure-Dir $outLatestDocDir
Ensure-Dir $outRunMdDir
Ensure-Dir $outRunDocDir
Ensure-Dir $outRunLogDir
Ensure-Dir $siteMdDir
Ensure-Dir $siteDocDir

# ---------- preflight ----------
Assert-File $courseYaml "Missing course yaml: $courseYaml"

if ($MODE -in @("full","md")) {
  Assert-File $engineMd "Missing MD engine: $engineMd"
}
if ($MODE -in @("full","docx","merge")) {
  Assert-File $renderPy "Missing DOCX renderer: $renderPy"
  Assert-File $tplCover "Missing template cover: $tplCover"
  Assert-File $tplBody  "Missing template body : $tplBody"
}

# ---------- Step C: YAML ensure ----------
if (!(Test-Path $week01Target)) {
  Assert-File $week01Source "Put week01.yaml here: $week01Source"
  Copy-Item $week01Source $week01Target -Force
  Write-Host "Copied week01.yaml -> $week01Target"
}

$missing = @()
foreach ($w in (2..16)) {
  $f = Join-Path $yamlDir ("week{0:d2}.yaml" -f $w)
  if (!(Test-Path $f)) { $missing += $f }
}
if ($missing.Count -gt 0) {
  Assert-File $genWeeksScript "Missing generator: $genWeeksScript"
  Write-Host "Generating week02..week16 YAML via: $genWeeksScript"
  powershell -ExecutionPolicy Bypass -File $genWeeksScript
}

foreach ($w in (Week-Ids)) {
  $p = Join-Path $yamlDir "$w.yaml"
  Assert-File $p "Week YAML missing: $p"
}
Write-Host "YAML ready."

# ---------- Step D: MD (optional) ----------
if ($MODE -in @("full","md")) {
  Write-Host "=== Step D: generate MD ==="
  foreach ($w in (Week-Ids)) {
    $inYaml = Join-Path $yamlDir "$w.yaml"
    $outRunMd = Join-Path $outRunMdDir "$w.lesson_plan.md"

    node $engineMd $courseYaml $inYaml $outRunMd
    if ($LASTEXITCODE -ne 0) { throw "Node engine failed for $w (exit=$LASTEXITCODE)" }

    Copy-Item $outRunMd (Join-Path $outLatestMdDir "$w.lesson_plan.md") -Force
    Copy-Item $outRunMd (Join-Path $siteMdDir (Split-Path $outRunMd -Leaf)) -Force
  }
  Write-Host "MD published to docs: $siteMdDir"
}

# ---------- Step E: DOCX (docx/docx-merge/full) ----------
$pyExe = (Get-Command python -ErrorAction Stop).Source
$env:PYTHONUTF8="1"
$env:PYTHONIOENCODING="utf-8"
$env:PYTHONUNBUFFERED="1"

$mergedRunDocx = Join-Path $outRunDocDir "lesson-plans.docx"
$mergedSiteDocx = Join-Path $siteDocDir "lesson-plans.docx"

if ($MODE -eq "docx") {
  Write-Host "=== Step E: render weekly DOCX only (no merge) ==="
  & $pyExe -u $renderPy --course-slug $courseSlug --term-slug $termSlug --out "$mergedRunDocx" --no-merge --dump-errors --debug
  if ($LASTEXITCODE -ne 0) { throw "DOCX weekly render failed (exit=$LASTEXITCODE)" }

  # publish weekly
  $tmpWeeksRun = Join-Path $outRunDocDir "_weeks_tmp"
  if (Test-Path $tmpWeeksRun -and $publishWeeklyDocxToSite) {
    $siteWeeks = Join-Path $siteDocDir "_weeks_tmp"
    Ensure-Dir $siteWeeks
    Copy-Item (Join-Path $tmpWeeksRun "*.docx") $siteWeeks -Force
    Write-Host "Weekly DOCX published: $siteWeeks"
  }
}

if ($MODE -eq "merge") {
  Write-Host "=== Step E: merge only (existing weekly docx) ==="
  & $pyExe -u $renderPy --course-slug $courseSlug --term-slug $termSlug --out "$mergedRunDocx" --merge-only --debug
  if ($LASTEXITCODE -ne 0) { throw "DOCX merge failed (exit=$LASTEXITCODE)" }

  # publish merged
  Copy-Item $mergedRunDocx $mergedSiteDocx -Force
  Copy-Item $mergedRunDocx (Join-Path $outLatestDocDir "lesson-plans.docx") -Force
  Write-Host "Merged DOCX published: $mergedSiteDocx"
}

if ($MODE -eq "full") {
  Write-Host "=== Step E: render weekly + merge ==="
  & $pyExe -u $renderPy --course-slug $courseSlug --term-slug $termSlug --out "$mergedRunDocx" --dump-errors --debug
  if ($LASTEXITCODE -ne 0) { throw "DOCX render+merge failed (exit=$LASTEXITCODE)" }

  Assert-File $mergedRunDocx "Merged docx missing: $mergedRunDocx"
  Copy-Item $mergedRunDocx $mergedSiteDocx -Force
  Copy-Item $mergedRunDocx (Join-Path $outLatestDocDir "lesson-plans.docx") -Force
  Write-Host "Merged DOCX published: $mergedSiteDocx"

  if ($publishWeeklyDocxToSite) {
    $tmpWeeksRun = Join-Path $outRunDocDir "_weeks_tmp"
    if (Test-Path $tmpWeeksRun) {
      $siteWeeks = Join-Path $siteDocDir "_weeks_tmp"
      Ensure-Dir $siteWeeks
      Copy-Item (Join-Path $tmpWeeksRun "*.docx") $siteWeeks -Force
      Write-Host "Weekly DOCX published: $siteWeeks"
    }
  }
}

Write-Host ""
Write-Host "DONE."
Write-Host "Run output: $outRunRoot"
Write-Host "Site md   : $siteMdDir"
Write-Host "Site docx : $siteDocDir"