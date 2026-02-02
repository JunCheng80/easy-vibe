---
title: MVP-1 总结
---
::: tip 🚀 直接开始：👉 请看 [快速开始](./quickstart) 
:::

# MVP-1：最小可用闭环（总结）

> 本页用于固化 MVP-1 的成果：命令怎么跑、产物在哪里、为什么命令变简单。
> 看完本页，哪怕隔几个月，也能 3 分钟恢复工作流。

## 1. MVP-1 闭环是什么？✅

**Course YAML + Lesson YAML**

**→ 模板渲染**

**→ 生成 Markdown**

**→ 写入站点 docs**

**→ 网页可见**

**→ 同时归档到 outputs**

- 工厂（生产/归档）：`lesson-builder/`
- 站点（展示/导航）：`docs/zh-cn/`


## 2. 快速开始（建议先看）🚀

- 快速开始：`./quickstart`

## 3. 输入是什么？（两类 YAML）🧩

### 3.1 课程级 YAML（Course YAML）
- 位置：`lesson-builder/00-input/courses/`
- 示例：`speech_appdev.dl.yaml`
- 含义：定义“这门课是什么”（低频变化）

### 3.2 周次级 YAML（Lesson YAML）
- 位置：`lesson-builder/00-input/lesson_specs/{courseSlug}/`
- 示例：`week01.yaml`
- 含义：定义“这一周教什么”（高频变化）

## 4. 命令怎么跑？（核心命令）🛠

```bash
node lesson-builder/10-engine/gen_lesson_plan.mjs \
  lesson-builder/00-input/courses/speech_appdev.dl.yaml \
  lesson-builder/00-input/lesson_specs/speech_appdev/week01.yaml
```

## 5. 为什么命令里不用写 outMd（站点输出路径）？📌

从 MVP-1 开始，输出路径策略已内置在 gen_lesson_plan.mjs 中：

- 从课程 YAML 文件名推断 courseSlug（如 speech_appdev）

- 从周次 YAML 文件名推断周次（如 week01）

- 默认输出到：docs/zh-cn/lesson-plans/{courseSlug}/weekXX.md

因此命令只需要提供两个输入 YAML，即可自动生成到网页目录。

## 6. 产物在哪里？📍

### 6.1. 网页展示🌐
    - docs/zh-cn/lesson-plans/{courseSlug}/weekXX.md
    - docs/zh-cn/lesson-plans/{courseSlug}/index.md（自动维护课程目录）

### 6.2. 工厂归档📦
    - lesson-builder/30-outputs/YYYY-MM-DD/weekXX.md

## 7. Stage-2（下一阶段方向）🔜 
- 脚手架：一键创建空的 weekXX.yaml
- sidebar 自动化：免手写 sidebar 配置
- Agent 接入：从 YAML → LLM → YAML 的自动生成链
