<#
================================================================================
run_16_weeks.ps1  |  Lesson Builder "One Command" Controller
================================================================================

你想要的目标：一个脚本，支持
- 单周 / 多周 / 全16周（all）生成
- docx / md / 合并 / 发布 的任意组合
- 进度条显示（不翻屏）
- Sleep=0 更快；也可 Sleep=1~2 更稳
- Clean 清理旧产物，解决“旧docx残留导致诡异问题”
- 把用法写在脚本里，直接复制粘贴命令即可

--------------------------------------------------------------------------------
【核心参数】
-Weeks      支持： "1" | "1,2" | "1-5" | "all"
-Actions    支持组合（逗号分隔）：
           docx   : 逐周生成 docx（最稳：每周单独 python 进程）
           md     : 逐周生成 md 并发布到 docs
           merge  : 合并 _weeks_tmp 下的周 docx -> lesson-plans.docx
           publish: 发布 docx 到 docs（发布哪些由开关控制）

-RunStamp   输出批次目录（默认自动：yyyyMMdd），可手动指定保证同一批次归档
-Clean      清除所选周的旧产物（强烈建议开启，避免“旧docx诡异问题”）
-SleepSeconds 周与周之间间隔：0=最快（默认0），若系统卡顿可设 1~2
-SkipFixTables  跳过 docx 后处理表格宽度（推荐：更快更稳）
-Quiet      少输出，不翻屏（配合进度条更清爽）

【发布开关】
-PublishMergedToDocs   发布合并总docx到 docs（常用）
-PublishWeeklyToDocs   发布每周docx到 docs（验收用）
说明：若 Actions 包含 publish 但你未指定以上两个开关，默认 PublishMergedToDocs=true。

--------------------------------------------------------------------------------
【输出位置（Run 工厂产出）】
lesson-builder/30-outputs/<CourseSlug>/<TermSlug>/<RunStamp>/
  md/    weekXX.lesson_plan.md
  docx/  lesson-plans.docx（merge后）
  docx/_weeks_tmp/  weekXX.lesson_plan.docx（每周docx）

【网站发布目录（docs）】
docs/zh-cn/lesson-plans/<CourseSlug>/<TermSlug>/
  md/    （md 发布）
  docx/  lesson-plans.docx（合并docx发布）
  docx/_weeks_tmp/（每周docx发布，可选）

--------------------------------------------------------------------------------
【你要的 8 种功能：命令示例（直接复制粘贴）】

（1）某一周 docx：例如 week02
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks 2 -Actions docx -Clean -SkipFixTables -SleepSeconds 0

（2）多周 docx：例如 week01-week05
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks 1-5 -Actions docx -Clean -SkipFixTables -SleepSeconds 0

（3）全16周 docx：all
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks all -Actions docx -Clean -SkipFixTables -SleepSeconds 0

（4）2-5：生成 docx + 合并（注意：只会合并2-5现有周）
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks 2-5 -Actions docx,merge -Clean -SkipFixTables -SleepSeconds 0

（5）1-16：生成 docx + 合并（标准总教案）
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks 1-16 -Actions docx,merge -Clean -SkipFixTables -SleepSeconds 0

（6）某一周 md：week02（生成+发布md）
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks 2 -Actions md -Clean -SleepSeconds 0

（7）多周 md：1-5（生成+发布md）
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks 1-5 -Actions md -Clean -SleepSeconds 0

（8）全套发布：all + docx + md + merge + publish（发布合并总docx）
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks all -Actions docx,md,merge,publish -Clean -SkipFixTables -SleepSeconds 0 `
  -PublishMergedToDocs

（8-扩展）全套发布 + 发布每周docx（验收用）
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\run_16_weeks.ps1 `
  -Weeks all -Actions docx,md,merge,publish -Clean -SkipFixTables -SleepSeconds 0 `
  -PublishMergedToDocs -PublishWeeklyToDocs

--------------------------------------------------------------------------------
【建议默认工作流（你已验证最稳）】
- 生成 docx：Actions=docx + -Clean + -SkipFixTables + SleepSeconds=0
- 最后需要总教案：再加 merge
- 需要站点下载：再加 publish + PublishMergedToDocs
================================================================================
#>

param(
  # -------------------------
  # 基础配置
  # -------------------------
  [string]$CourseSlug = "speech_appdev",
  [string]$TermSlug   = "2026S3",
  [string]$RunStamp   = "",                  # 默认自动 yyyyMMdd
  [string]$Weeks      = "all",               # 1 | 1,2 | 1-5 | all
  [string]$Actions    = "docx",              # docx,md,merge,publish 任意组合

  # -------------------------
  # 稳定性/性能
  # -------------------------
  [switch]$SkipFixTables,                    # 推荐：更快更稳
  [int]$SleepSeconds  = 0,                   # 默认0；卡顿可调1~2
  [switch]$Clean,                            # 推荐：避免旧docx残留干扰
  [switch]$Quiet,                            # 更少输出，配合进度条

  # -------------------------
  # 发布到 docs
  # -------------------------
  [switch]$PublishWeeklyToDocs,
  [switch]$PublishMergedToDocs
)

$ErrorActionPreference = "Stop"

# -------------------------
# Helpers
# -------------------------
function Ensure-Dir([string]$p) { New-Item -ItemType Directory -Force -Path $p | Out-Null }

function Assert-File([string]$p, [string]$hint) {
  if ([string]::IsNullOrWhiteSpace($p) -or !(Test-Path $p)) { throw "Missing: $p`nHint: $hint" }
}

function Parse-Weeks([string]$s) {
  $s = $s.Trim().ToLower()
  if ($s -eq "all") { return 1..16 }

  if ($s.Contains(",")) {
    $nums = $s.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | ForEach-Object { [int]$_ }
    return $nums | Sort-Object -Unique
  }

  if ($s.Contains("-")) {
    $parts = $s.Split("-") | ForEach-Object { $_.Trim() }
    if ($parts.Count -ne 2) { throw "Invalid Weeks range: $s" }
    $a = [int]$parts[0]; $b = [int]$parts[1]
    if ($a -lt 1 -or $b -gt 16 -or $a -gt $b) { throw "Invalid Weeks range: $s (expect 1..16 and start<=end)" }
    return $a..$b
  }

  return @([int]$s)
}

function Has-Action([string[]]$list, [string]$name) { return ($list -contains $name.ToLower()) }
function WeekId([int]$w) { return ("week{0:d2}" -f $w) }

# -------------------------
# Defaults / Parse
# -------------------------
if ([string]::IsNullOrWhiteSpace($RunStamp)) { $RunStamp = (Get-Date -Format "yyyyMMdd") }

$weeksList = Parse-Weeks $Weeks

$actList = $Actions.Split(",") | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ -ne "" } | Sort-Object -Unique
if ($actList.Count -eq 0) { $actList = @("docx") }

$doDocx    = Has-Action $actList "docx"
$doMd      = Has-Action $actList "md"
$doMerge   = Has-Action $actList "merge"
$doPublish = Has-Action $actList "publish"

# publish 默认行为：如果写了 publish 但没指定发布哪些，默认发布 merged
if ($doPublish -and -not $PublishMergedToDocs -and -not $PublishWeeklyToDocs) {
  $PublishMergedToDocs = $true
}

# -------------------------
# Paths
# -------------------------
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

$oneWeek  = Join-Path $PSScriptRoot "build_one_week.ps1"
$engineMd = Join-Path $repoRoot "lesson-builder\10-engine\gen_lesson_plan.mjs"
$renderPy = Join-Path $repoRoot "lesson-builder\10-engine\render_lesson_plans_docx.py"

$pyExe = (Get-Command python -ErrorAction Stop).Source
$env:PYTHONUTF8="1"
$env:PYTHONIOENCODING="utf-8"
$env:PYTHONUNBUFFERED="1"

$outRunRoot    = Join-Path $repoRoot "lesson-builder\30-outputs\$CourseSlug\$TermSlug\$RunStamp"
$outRunMdDir   = Join-Path $outRunRoot "md"
$outRunDocDir  = Join-Path $outRunRoot "docx"
$tmpWeeksDir   = Join-Path $outRunDocDir "_weeks_tmp"
$mergedRunDocx = Join-Path $outRunDocDir "lesson-plans.docx"

$siteRoot       = Join-Path $repoRoot "docs\zh-cn\lesson-plans\$CourseSlug\$TermSlug"
$siteMdDir      = Join-Path $siteRoot "md"
$siteDocDir     = Join-Path $siteRoot "docx"
$siteWeeksDir   = Join-Path $siteDocDir "_weeks_tmp"
$siteMergedDocx = Join-Path $siteDocDir "lesson-plans.docx"

Ensure-Dir $outRunMdDir
Ensure-Dir $outRunDocDir
Ensure-Dir $tmpWeeksDir
Ensure-Dir $siteMdDir
Ensure-Dir $siteDocDir

# -------------------------
# Header
# -------------------------
Write-Host "================ CONFIG ================"
Write-Host "CourseSlug=$CourseSlug  TermSlug=$TermSlug  RunStamp=$RunStamp"
Write-Host "Weeks=$Weeks -> [$($weeksList -join ',')]"
Write-Host "Actions=$Actions -> [$($actList -join ',')]"
Write-Host "SleepSeconds=$SleepSeconds  SkipFixTables=$SkipFixTables  Clean=$Clean  Quiet=$Quiet"
Write-Host "PublishWeeklyToDocs=$PublishWeeklyToDocs  PublishMergedToDocs=$PublishMergedToDocs"
Write-Host "========================================"

# -------------------------
# Clean old artifacts (fix your 'weird 4-week issue')
# -------------------------
if ($Clean) {
  if (-not $Quiet) { Write-Host "🧹 Cleaning old artifacts for selected weeks..." }

  foreach ($w in $weeksList) {
    $wid = WeekId $w
    $oldWeekDocx = Join-Path $tmpWeeksDir "$wid.lesson_plan.docx"
    if (Test-Path $oldWeekDocx) { Remove-Item $oldWeekDocx -Force }

    $oldWeekMd = Join-Path $outRunMdDir "$wid.lesson_plan.md"
    if (Test-Path $oldWeekMd) { Remove-Item $oldWeekMd -Force }
  }

  if (Test-Path $mergedRunDocx) { Remove-Item $mergedRunDocx -Force }

  if (-not $Quiet) { Write-Host "✅ Clean done." }
}

# -------------------------
# 1) Generate week-by-week with progress bar
# -------------------------
$idx = 0
$total = $weeksList.Count

foreach ($w in $weeksList) {
  $idx++
  $wid = WeekId $w
  $percent = [int](($idx / $total) * 100)

  # Write-Progress -Activity "Lesson Builder ($CourseSlug $TermSlug $RunStamp)" -Status "Processing $wid ($idx/$total)" -PercentComplete $percent

  if (-not $Quiet) {
    Write-Host ""
    Write-Host "================ RUN $wid ($idx/$total) ================"
  }

  # DOCX (stable: one week -> one python process)
  if ($doDocx) {
    $argsList = @(
      "-CourseSlug", $CourseSlug,
      "-TermSlug", $TermSlug,
      "-WeekNo", "$w",
      "-Mode", "docx",
      "-RunStamp", $RunStamp
    )
    if ($SkipFixTables) { $argsList += "-SkipFixTables" }

    powershell -ExecutionPolicy Bypass -File $oneWeek @argsList
  }

  # MD (generate and publish per week)
  if ($doMd) {
    Assert-File $engineMd "Missing MD engine: $engineMd"
    $courseYaml = Join-Path $repoRoot "lesson-builder\00-input\courses\$CourseSlug.dl.yaml"
    $weekYaml   = Join-Path $repoRoot "lesson-builder\00-input\lesson_specs\$CourseSlug\yaml\$wid.yaml"
    Assert-File $courseYaml "Missing course yaml: $courseYaml"
    Assert-File $weekYaml   "Missing week yaml: $weekYaml"

    $outMd  = Join-Path $outRunMdDir "$wid.lesson_plan.md"
    node $engineMd $courseYaml $weekYaml $outMd
    if ($LASTEXITCODE -ne 0) { throw "MD engine failed for $wid (exit=$LASTEXITCODE)" }

    Copy-Item $outMd (Join-Path $siteMdDir (Split-Path $outMd -Leaf)) -Force
    if (-not $Quiet) { Write-Host "✅ MD OK+Published: $outMd" }
  }

  if ($SleepSeconds -gt 0) { Start-Sleep -Seconds $SleepSeconds }
}

# Write-Progress -Activity "Lesson Builder ($CourseSlug $TermSlug $RunStamp)" -Completed -Status "Done"

Write-Host ""
Write-Host "✅ Generate done. RunStamp=$RunStamp Weeks=$Weeks"

# -------------------------
# 2) Merge (optional)
# -------------------------
if ($doMerge) {
  Assert-File $renderPy "Missing renderer: $renderPy"
  Assert-File $tmpWeeksDir "Missing weekly docx folder: $tmpWeeksDir"

  Write-Host ""
  Write-Host "================ MERGE ================"
  Write-Host "Weekly dir: $tmpWeeksDir"
  Write-Host "Out docx : $mergedRunDocx"

  & $pyExe -u $renderPy --course-slug $CourseSlug --term-slug $TermSlug --out "$mergedRunDocx" --merge-only --debug
  if ($LASTEXITCODE -ne 0) { throw "Merge failed (exit=$LASTEXITCODE)" }

  Assert-File $mergedRunDocx "Merged docx missing: $mergedRunDocx"
  Write-Host "✅ MERGE OK: $mergedRunDocx"
}

# -------------------------
# 3) Publish (optional)
# -------------------------
if ($doPublish) {
  Write-Host ""
  Write-Host "================ PUBLISH ================"

  if ($PublishMergedToDocs) {
    Assert-File $mergedRunDocx "Publish merged requested but not found: $mergedRunDocx"
    Copy-Item $mergedRunDocx $siteMergedDocx -Force
    Write-Host "✅ Published merged docx -> $siteMergedDocx"
  }

  if ($PublishWeeklyToDocs) {
    Assert-File $tmpWeeksDir "Publish weekly requested but folder missing: $tmpWeeksDir"
    Ensure-Dir $siteWeeksDir
    Copy-Item (Join-Path $tmpWeeksDir "*.docx") $siteWeeksDir -Force
    Write-Host "✅ Published weekly docx -> $siteWeeksDir"
  }
}

Write-Host ""
Write-Host "DONE."
Write-Host "Run outputs: $outRunRoot"
Write-Host "Docs md    : $siteMdDir"
Write-Host "Docs docx  : $siteDocDir"