param(
  [Parameter(Mandatory=$true)][string]$CourseSlug,
  [Parameter(Mandatory=$true)][string]$TermSlug,
  [Parameter(Mandatory=$true)][int]$WeekNo,
  [string]$Mode = "docx",          # md | docx | both
  [string]$RunStamp = "",          # 默认今天 yyyyMMdd；外层循环建议固定一个 RunStamp
  [switch]$SkipFixTables           # 传入则给 python 加 --skip-fix-tables（更省资源）
)

$ErrorActionPreference = "Stop"

function Ensure-Dir([string]$p) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
function Assert-File([string]$p, [string]$hint) {
  if ([string]::IsNullOrWhiteSpace($p) -or !(Test-Path $p)) { throw "Missing: $p`nHint: $hint" }
}

# ---------- repo root ----------
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

# ---------- runStamp ----------
if ([string]::IsNullOrWhiteSpace($RunStamp)) { $RunStamp = (Get-Date -Format "yyyyMMdd") }

# ---------- normalize week ----------
$weekId = "week{0:d2}" -f $WeekNo

# ---------- paths ----------
$courseYaml = Join-Path $repoRoot "lesson-builder\00-input\courses\$CourseSlug.dl.yaml"
$yamlDir    = Join-Path $repoRoot "lesson-builder\00-input\lesson_specs\$CourseSlug\yaml"
$weekYaml   = Join-Path $yamlDir "$weekId.yaml"

$engineMd   = Join-Path $repoRoot "lesson-builder\10-engine\gen_lesson_plan.mjs"
$renderPy   = Join-Path $repoRoot "lesson-builder\10-engine\render_lesson_plans_docx.py"

# factory outputs
$outRunRoot   = Join-Path $repoRoot "lesson-builder\30-outputs\$CourseSlug\$TermSlug\$RunStamp"
$outRunMdDir  = Join-Path $outRunRoot "md"
$outRunDocDir = Join-Path $outRunRoot "docx"
$outRunLogDir = Join-Path $outRunRoot "_logs"

Ensure-Dir $outRunMdDir
Ensure-Dir $outRunDocDir
Ensure-Dir $outRunLogDir

Assert-File $courseYaml "Check course yaml"
Assert-File $weekYaml   "Check week yaml exists: $weekYaml"

# ---------- MD (single week) ----------
if ($Mode -in @("md","both")) {
  Assert-File $engineMd "Missing md engine"
  $outMd = Join-Path $outRunMdDir "$weekId.lesson_plan.md"
  node $engineMd $courseYaml $weekYaml $outMd
  if ($LASTEXITCODE -ne 0) { throw "MD engine failed for $weekId (exit=$LASTEXITCODE)" }
  Write-Host "✅ MD OK: $outMd"
}

# ---------- DOCX (single week) ----------
if ($Mode -in @("docx","both")) {
  Assert-File $renderPy "Missing docx renderer"

  $pyExe = (Get-Command python -ErrorAction Stop).Source
  $env:PYTHONUTF8="1"
  $env:PYTHONIOENCODING="utf-8"
  $env:PYTHONUNBUFFERED="1"

  # 单周输出：我们仍然输出到 run/docx/_weeks_tmp 下（与 merge 兼容）
  $outMergedDummy = Join-Path $outRunDocDir "lesson-plans.docx"  # 渲染器要求 --out，但我们用 --no-merge
  $stdoutLog = Join-Path $outRunLogDir ("week_{0}_{1}.out.log" -f $weekId, $RunStamp)
  $stderrLog = Join-Path $outRunLogDir ("week_{0}_{1}.err.log" -f $weekId, $RunStamp)

  "START $weekId at $(Get-Date) (py=$pyExe)" | Add-Content -Path $stdoutLog -Encoding UTF8
  "START $weekId at $(Get-Date) (py=$pyExe)" | Add-Content -Path $stderrLog -Encoding UTF8

  # 只跑这一周：--from-week/--to-week
  $cmd = "`"$pyExe`" -u `"$renderPy`" --course-slug $CourseSlug --term-slug $TermSlug --out `"$outMergedDummy`" --from-week $WeekNo --to-week $WeekNo --no-merge --dump-errors --debug"
  if ($SkipFixTables) { $cmd = $cmd + " --skip-fix-tables" }

  cmd /c "$cmd 1>> `"$stdoutLog`" 2>> `"$stderrLog`""
  if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ DOCX failed for $weekId. See logs:"
    Write-Host "  OUT: $stdoutLog"
    Write-Host "  ERR: $stderrLog"
    throw "DOCX failed for $weekId (exit=$LASTEXITCODE)"
  }

  $weekDocx = Join-Path $outRunDocDir "_weeks_tmp\$weekId.lesson_plan.docx"
  Assert-File $weekDocx "Expected weekly docx not found: $weekDocx"
  Write-Host "✅ DOCX OK: $weekDocx"
}

Write-Host "🎯 DONE one week: $weekId (Mode=$Mode, RunStamp=$RunStamp)"