---
title: MVP-2 Playbook｜一条命令批量生成三要件 + 教案 + PPT脚本 + 自动归档
---

# MVP-2 Playbook｜一条命令批量生成三要件 + 教案 + PPT脚本 + 自动归档

> 目的：把“备课”从手工写作，升级为“填结构 + 批量生成 + 自动归档 + 网站可浏览”。  
> 当前示范课程：`speech_appdev`（智能语音处理及应用开发）｜学期：`2026S2`

---

## 1. 一句话验收标准（MVP-2 Done）

对任意课程（courseId）与任意学期（term），执行一条命令即可：

- 自动生成**三要件**（教学大纲 / 教学进度表 / 教案）
- 自动生成**16周产出**（week01~week16）
- 每周至少生成**2套PPT脚本**（不足自动补齐）
- 生成 **manifest.json** 与 **todo_report.md**（可追踪、可检查）
- 自动归档到 `docs/` 并在 VitePress 网站中可直接浏览
- sidebar 自动随目录变化更新（无需手填课程项）

---

## 2. 目录约定（你只需要记住这几个路径）

### 2.1 输入（00-input）

- 课程配置：  
  `lesson-builder/00-input/courses/<courseId>.<term>.course.yaml`
- 每周输入（按课程分目录）：  
  `lesson-builder/00-input/weeks/<courseId>/week01.yaml`  
  `lesson-builder/00-input/weeks/<courseId>/week02.yaml`  
  ...  
  `lesson-builder/00-input/weeks/<courseId>/week16.yaml`

> 命名要求：`weekXX.yaml`（XX 为 01~16），否则不会被脚本读取。

### 2.2 规则（00-rules）

- 质量规则（占位符扫描等）：  
  `lesson-builder/00-rules/policies/quality_policy.yaml`
- PPT策略（每周最少套数、默认deck骨架等）：  
  `lesson-builder/00-rules/policies/ppt_policy.yaml`

### 2.3 模板（20-templates）

- `lesson-builder/20-templates/syllabus.md.hbs`（教学大纲）
- `lesson-builder/20-templates/calendar.md.hbs`（教学进度表）
- `lesson-builder/20-templates/lesson_plan.md.hbs`（课程教案/周教案）
- `lesson-builder/20-templates/ppt_deck.md.hbs`（PPT脚本）

### 2.4 输出（30-outputs）

- 生成输出（原始产物）：  
  `lesson-builder/30-outputs/<courseId>/<term>/`

### 2.5 归档（docs）

- 网站可浏览产物（镜像归档）：  
  `docs/zh-cn/lesson-plans/<courseId>/<term>/`
- 归档目录自动生成入口页：  
  `docs/zh-cn/lesson-plans/<courseId>/<term>/index.md`

---

## 3. 一键命令（最常用的两条）

### 3.1 常规覆盖更新（默认会覆盖同名文件）

```bash
node lesson-builder/10-engine/build.mjs speech_appdev 2026S2
```

### 3.2 清空重建（推荐在“规则/命名/周数变化”后使用）

```bash
node lesson-builder/10-engine/build.mjs speech_appdev 2026S2 --clean
```

> `--clean` 会清空并重建两处目录：  
> - `lesson-builder/30-outputs/<courseId>/<term>/`  
> - `docs/zh-cn/lesson-plans/<courseId>/<term>/`  
> 目的：避免旧文件残留（例如过去生成过 ppt03，但现在策略只需要 ppt01/ppt02）。

---

## 4. 输出清单（生成后你应该看到什么）

执行 build 后，在以下两个目录都应看到一致产物：

- `lesson-builder/30-outputs/speech_appdev/2026S2/`
- `docs/zh-cn/lesson-plans/speech_appdev/2026S2/`

### 4.1 三要件（MVP-2 三件套）

- `syllabus.md`：教学大纲
- `calendar.md`：教学进度表
- `weekXX.lesson_plan.md`：周教案（week01~week16）

### 4.2 PPT脚本（每周至少2套）

- `week01.ppt01.md`、`week01.ppt02.md`
- `week02.ppt01.md`、`week02.ppt02.md`
- ...
- `week16.ppt01.md`、`week16.ppt02.md`

> 若某周 `weekXX.yaml` 中 `ppt_decks` 不足 2 套，会按 ppt_policy 自动补齐，并记录在 todo_report 中。

### 4.3 可追踪文件

- `manifest.json`：生成时间、输入路径、输出列表、统计信息
- `todo_report.md`：占位符待完善清单（输入/输出双向扫描）

### 4.4 入口页（归档目录自动生成）

- `index.md`：列出 syllabus / calendar / todo_report / week 文件入口链接

---

## 5. 规则机制说明（为什么要有 rules）

### 5.1 quality_policy.yaml（质量占位符扫描）

- `placeholder_keywords` 定义哪些文本算“待完善”
- build 会：
  - 扫描输入 `weekXX.yaml` 是否存在占位符
  - 扫描输出 `.md` 是否存在占位符
  - 汇总到 `todo_report.md`

### 5.2 ppt_policy.yaml（PPT批量生产策略）

- `ppt_per_week_min`：每周至少需要多少套 PPT 脚本（默认 2）
- `default_deck`：自动补齐 deck 的默认结构（导入、提纲、随堂题、总结、作业等）

---

## 6. 常见问题（3条够用）

### Q1：我改了 config.mjs/sidebar，但页面不更新？

- **重启 VitePress dev server**（Ctrl+C 后重新 `npm run docs:dev`）
- 必要时清缓存：
  - `docs/.vitepress/.cache`
  - `docs/.vitepress/dist`

### Q2：我改了“每周PPT套数/命名规则”，但目录里还有旧文件残留？

- 使用 `--clean` 重建：  
  `node ... build.mjs <courseId> <term> --clean`

### Q3：某周没有生成内容？

检查 `lesson-builder/00-input/weeks/<courseId>/weekXX.yaml` 是否：

- 文件存在
- 命名符合 `week\d+\.yaml`
- 已保存（常见：复制后忘记保存）

---

## 7. 下一步路线图（进入 MVP-3）

> MVP-2 已实现“能批量生成 + 可浏览 + 可追踪”。  
> MVP-3 的目标是“**规则化校验**”：让系统在生成前就挡住错误。

建议从这三类校验开始：

1) **必填字段校验**：缺字段直接报错/警告（防漏项）  
2) **一致性校验**：周数=16？每周PPT≥2？学时合计是否合理？  
3) **占位符阈值**：todo 过多时提示“质量风险”（不一定拦截）

---

## 8. Demo（当前示范课入口）

- 总览：`/zh-cn/lesson-plans/`
- 智能语音处理及应用开发（2026S2）：  
  `/zh-cn/lesson-plans/speech_appdev/2026S2/`

（sidebar 已支持自动扫描目录，无需手填课程项）
