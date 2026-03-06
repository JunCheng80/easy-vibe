---
title: MVP-3 总结｜Word 教案一键生成（docxtpl）
---

# MVP-3 总结｜Word 教案一键生成（docxtpl）

## 1. MVP-3 做成了什么

目标：针对课程 **智能语音应用和开发（speech_appdev）**，实现“一键生成”整学期教案 Word：

- **1 个封面**
- **week01 ~ week16 正文教案**
- 合并为 **1 个 docx（lesson-plans.docx）**
- 同步到站点目录，便于网页侧下载/留档

最终产物（核心输出）：

- `lesson-builder/30-outputs/speech_appdev/2026S3/docx/lesson-plans.docx`
- `docs/zh-cn/lesson-plans/speech_appdev/2026S3/docx/lesson-plans.docx`

---

## 2. 一键运行（最常用）

> 在仓库根目录 `easy-vibe/` 执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\lesson-builder\10-engine\build_2026S3.ps1