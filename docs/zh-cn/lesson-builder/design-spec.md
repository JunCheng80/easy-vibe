---
title: 备课生成器｜设计说明书（Design Spec）
---

# 备课生成器（Lesson Builder）设计说明书

> 本文档用于固化“备课生成器”的开发路线、模块边界与后续可扩展点。  
> 目标：不额外写笔记，直接以项目内文档作为实施依据与参考资料。

---

## 1. 项目定位

### 1.1 目标
将备课从“写文章”变成“填结构 + 组合装配”，并为后续 AI/Agent 自动生成奠定输入/输出规范。

### 1.2 核心原则
- **结构先行**：先定义稳定的备课结构，再谈自动化与美化
- **最小可用**：先跑通“Stage-0 → Stage-1”的最小闭环
- **可复用可扩展**：内容按模块组织，便于课程迁移、批量生成与后续接入 Agent

---

## 2. 信息架构（IA）

建议目录结构：

- `/zh-cn/lesson-builder/index.md`：入口页（Home 布局，产品化入口）
- `/zh-cn/lesson-builder/quickstart.md`：快速开始（告诉我怎么用）
- `/zh-cn/lesson-builder/stage-0.md`：输入表单（课程元信息 + 约束）
- `/zh-cn/lesson-builder/stage-1.md`：章节/课时安排（骨架输出）
- `/zh-cn/lesson-builder/stage-2.md`：课时内容模板（讲解结构）
- `/zh-cn/lesson-builder/stage-3.md`：作业/实验与评分（评价输出）
- `/zh-cn/lesson-builder/design-spec.md`：本文件（设计说明书）

---

## 3. 三天实施路线图（MVP）

### Day 1｜理解与可运行（工程地基）
**目标：**能跑、能改、能解释  
**验收：**
- 能启动项目并热更新
- 理解 `docs/zh-cn/index.md` 与 `docs/.vitepress/config.mjs` 的作用
- 明白 nav/sidebar 与目录页面的对应关系

### Day 2｜建立模块空间（Lesson Builder 落地）
**目标：**搭出专属模块并可进入  
**动作：**
- 新建 `lesson-builder/` 模块目录
- 完成 `index.md`（入口页）+ `quickstart.md`（流程说明）+ `stage-0.md`（输入表单）
- 接入 nav/sidebar，保证入口稳定
**验收：**
- 网页可进入“备课生成器”
- stage-0 能作为“填表式输入”被复用

### Day 3｜跑通最小闭环（Stage-0 → Stage-1）
**目标：**形成“生成器”的最小功能感  
**动作：**
- 增加 `stage-1.md`：章节/课时安排模板
- 以“手动复制粘贴”方式从 stage-0 生成 stage-1（先验证流程）
**验收：**
- 任意课程都能在 10 分钟内形成“课时骨架表”
- 结构统一、可复用

---

## 4. 工作流定义（输入 → 生成 → 校验 → 输出）

### 4.1 Input（Stage-0）
- 课程基础信息（对象、学时、教材）
- 输出物选择（Stage-1/2/3 勾选）
- 约束条件（风格、禁用项、必讲点）

### 4.2 Generate（Stage-1/2/3）
- Stage-1：章节/周次/课时安排表
- Stage-2：每课时内容模板（目标→重难点→讲解→案例→互动）
- Stage-3：作业/实验清单与评分标准

### 4.3 Check（质量一致性）
- 目标与内容是否对应？
- 重难点是否覆盖？
- 活动是否可执行？
- 作业是否可评价？

### 4.4 Output（导出形态）
- 当前：Markdown（最稳的中间形态）
- 后续：Word/PPT（模板导出或自动转换）

---

## 5. Agent 接入点（未来扩展）

当“手动闭环”稳定后，再引入 Agent：

- **Agent 输入**：读取 Stage-0（结构化字段）
- **Agent 输出**：自动生成 Stage-1/2/3
- **Agent 校验**：输出一致性检查清单 + 建议改写
- **批量生成**：对多门课/多章节自动生成并保持风格一致

---

## 6. 当前待办清单（可滚动更新）
- [ ] 完成 Stage-1 模板页并跑通 Stage-0 → Stage-1
- [ ] 完成 sidebar（Lesson Builder 下 4~6 个入口）
- [ ] 增加 Stage-2/Stage-3 模板页
- [ ] 评估 Agent 介入方式
