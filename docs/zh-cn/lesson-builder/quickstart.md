---
title: 快速开始
---
::: tip 先看全局 & 直接开跑
- 先看闭环：👉 [MVP-1 总结](./mvp-1)
- 直接开跑：👇 下滑到「🚀 快速开始（3 行命令版）」
:::

# 快速开始：从 Stage-0 到可用的备课骨架

## 目标
用 10 分钟做出一门课的“备课骨架”，并可复用。

## 步骤
1. 打开并填写：[Stage 0｜课程信息输入](/zh-cn/lesson-builder/stage-0)
2. 复制 Stage-0 中的关键信息：课程名 / 学时 / 必讲内容 / 风格约束
3. （下一步）生成 Stage-1：章节与课时安排（先手动做，后续用 Agent 自动做）

## 输出物
- 一份可复用的课程输入模板（Stage-0）
- 一份章节/课时结构骨架（Stage-1：下一阶段补）


# Stage-1：MVP-1常用命令集

## 🚀 快速开始（3 行命令版）

1️⃣ 准备输入  
- 课程配置：`lesson-builder/00-input/courses/speech_appdev.dl.yaml`  
- 周次配置：`lesson-builder/00-input/lesson_specs/speech_appdev/week01.yaml`

2️⃣ 生成备课内容  
```bash
node lesson-builder/10-engine/gen_lesson_plan.mjs  lesson-builder/00-input/courses/speech_appdev.dl.yaml lesson-builder/00-input/lesson_specs/speech_appdev/week01.yaml
```

3️⃣ 查看结果

🌐 网页展示：/zh-cn/lesson-plans/speech_appdev/week01

📦 工厂归档：lesson-builder/30-outputs/YYYY-MM-DD/week01.md
