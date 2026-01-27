---
title: 备课首页
---

<div class="lb-hero">

# 备课生成器（Lesson Builder）

<div class="lb-tagline">
把“备课”从写长文，变成 <b>填结构 + 组合装配</b>。<br/>
先跑通 Stage-0（课程输入），再按需生成：章节安排、课时内容、作业与评价。
</div>

<div class="lb-actions">
  <a class="lb-btn primary" href="/zh-cn/lesson-builder/quickstart">🚀 快速开始</a>
  <a class="lb-btn" href="/zh-cn/lesson-builder/stage-0">🧾 课程输入｜Stage-0</a>
  <a class="lb-btn" href="/zh-cn/lesson-builder/design-spec">📘 设计说明</a>

</div>


<div class="lb-rotating">
  <RotatingTagline
    :items="[
      '把经验型备课，升级为可传承、可复用、可持续演进的结构化教学设计体系🚀',
      '减少低价值的重复劳动，把时间真正还给教学设计、课堂节奏与学生参与⚡',
      '一套结构支撑多门课程与多轮授课，实现跨学期、跨课程的稳定复用♻️',
      '引入 AI 辅助生成，并坚持教师主控，让产出始终可控、可改、可交付✅'
    ]"
    :interval="3200"
    :typeSpeed="55"
    :deleteSpeed="28"
    :pause="900"
    size="normal"
  />
</div>
</div> <!-- ✅ 这一行必须存在：闭合 lb-hero -->

---

## 你会得到什么？

<div class="lb-cards">
  <div class="lb-card">
    <div class="lb-card-title">标准化备课结构</div>
    <div class="lb-card-desc">统一“目标-重难点-活动-作业-评价”，减少随意性与返工。</div>
  </div>
  <div class="lb-card">
    <div class="lb-card-title">可复用、可批量</div>
    <div class="lb-card-desc">课程配置 + 模板装配：做一次，复用多次，同类课程一键迁移。</div>
  </div>
  <div class="lb-card">
    <div class="lb-card-title">为 AI/Agent 预留接口</div>
    <div class="lb-card-desc">后续支持自动补全、风格统一、逻辑校验、讲义/PPT 大纲生成。</div>
  </div>
</div>

---

## 三步启动（MVP）

<div class="lb-steps">

<div class="lb-step">
  <div class="lb-step-title">Step 1｜先把输入做对（Stage-0）</div>
  <div class="lb-step-desc">课程基本信息 + 产出选择 + 质量约束 = 后续生成的唯一可信输入源。</div>
  <a class="lb-link" href="/zh-cn/lesson-builder/stage-0">进入 Stage-0 →</a>
</div>

<div class="lb-step">
  <div class="lb-step-title">Step 2｜按你勾选的产出逐步生成</div>
  <div class="lb-step-desc">章节/周次安排 → 课时内容 → 作业与评价。你只生成你需要的部分。</div>
  <a class="lb-link" href="/zh-cn/lesson-builder/quickstart">查看快速开始 →</a>
</div>

<div class="lb-step">
  <div class="lb-step-title">Step 3｜用“设计说明”保证方向不跑偏</div>
  <div class="lb-step-desc">把它当成产品说明书 + 开发路线图：未来接入 Agent 时会非常省心。</div>
  <a class="lb-link" href="/zh-cn/lesson-builder/design-spec">查看设计说明 →</a>
</div>

</div>

---

## 我现在应该点哪个？

- 想马上用起来：**[快速开始](/zh-cn/lesson-builder/quickstart)**
- 想把输入表单打磨扎实：**[课程输入｜Stage-0](/zh-cn/lesson-builder/stage-0)**
- 想按路线推进开发、不额外做笔记：**[设计说明](/zh-cn/lesson-builder/design-spec)**

---

<style>
/* ==== 广告感：动态背景光斑 + 渐变标题 + 卡片浮动 ==== */

.lb-hero{
  position: relative;
  overflow: hidden;
  padding: 18px 18px 10px 18px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 16px;
  background: linear-gradient(180deg, var(--vp-c-bg-soft), var(--vp-c-bg));
  box-shadow: 0 10px 40px rgba(0,0,0,.06);
}

.lb-hero::before,
.lb-hero::after{
  content: "";
  position: absolute;
  width: 520px;
  height: 520px;
  border-radius: 50%;
  filter: blur(48px);
  opacity: .35;
  pointer-events: none;
  transform: translate3d(0,0,0);
  animation: lb-float 10s ease-in-out infinite;
}

.lb-hero::before{
  top: -220px;
  left: -200px;
  background: radial-gradient(circle, rgba(99,102,241,.55), transparent 60%);
}
.lb-hero::after{
  bottom: -240px;
  right: -220px;
  background: radial-gradient(circle, rgba(236,72,153,.55), transparent 60%);
  animation-duration: 12s;
}

@keyframes lb-float{
  0%   { transform: translate(0,0) scale(1); }
  50%  { transform: translate(30px,18px) scale(1.06); }
  100% { transform: translate(0,0) scale(1); }
}

/* 标题：渐变流动（广告感核心） */
.lb-hero h1{
  display: inline-block;
  background: linear-gradient(90deg, #4f46e5, #ec4899, #22c55e, #4f46e5);
  background-size: 300% 100%;
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  animation: lb-gradient 6s linear infinite;
}
@keyframes lb-gradient{
  0% { background-position: 0% 50%; }
  100% { background-position: 100% 50%; }
}

.lb-tagline{
  margin-top: 10px;
  line-height: 1.75;
  font-size: 15px;
  color: var(--vp-c-text-2);
}

/* 按钮：呼吸高亮 + hover 弹起 */
.lb-actions{
  margin-top: 14px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.lb-btn{
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 9px 13px;
  border-radius: 12px;
  border: 1px solid var(--vp-c-divider);
  background: rgba(255,255,255,.65);
  backdrop-filter: blur(6px);
  color: var(--vp-c-text-1);
  text-decoration: none !important;
  font-weight: 700;
  transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
}

.lb-btn.primary{
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 8px 22px rgba(79,70,229,.18);
  animation: lb-pulse 2.4s ease-in-out infinite;
}
@keyframes lb-pulse{
  0%,100% { box-shadow: 0 8px 22px rgba(79,70,229,.18); }
  50%     { box-shadow: 0 12px 30px rgba(236,72,153,.20); }
}

.lb-btn:hover{
  transform: translateY(-2px);
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 14px 38px rgba(0,0,0,.10);
}

/* 卡片：hover 浮起，默认轻阴影 */
.lb-cards{
  margin-top: 10px;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
}

.lb-card{
  padding: 14px;
  border-radius: 16px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
  box-shadow: 0 10px 30px rgba(0,0,0,.05);
  transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
}
.lb-card:hover{
  transform: translateY(-3px);
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 18px 46px rgba(0,0,0,.10);
}

.lb-card-title{
  font-weight: 900;
  margin-bottom: 6px;
}
.lb-card-desc{
  color: var(--vp-c-text-2);
  line-height: 1.6;
  font-size: 14px;
}

/* Steps：更像“广告页的分段模块” */
.lb-steps{
  display: grid;
  gap: 10px;
}
.lb-step{
  padding: 14px;
  border-radius: 16px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  box-shadow: 0 10px 28px rgba(0,0,0,.04);
  transition: transform .18s ease, box-shadow .18s ease;
}
.lb-step:hover{
  transform: translateY(-2px);
  box-shadow: 0 16px 44px rgba(0,0,0,.08);
}

.lb-step-title{ font-weight: 900; margin-bottom: 6px; }
.lb-step-desc{ color: var(--vp-c-text-2); line-height: 1.6; margin-bottom: 6px; }

.lb-link{
  text-decoration: none !important;
  font-weight: 800;
  color: var(--vp-c-brand-1);
}

@media (max-width: 960px){
  .lb-cards{ grid-template-columns: 1fr; }
}


/* RotatingTagline：做成“首页广告条” */
.lb-rotating{
  margin-top: 18px;        /* Hero 到广告条：呼吸感 */
  padding-top: 10px;
  border-top: 1px solid var(--vp-c-divider);
}

/* 让 RotatingTagline 这一行更“轻、优雅、有品牌感” */
.lb-rotating :deep(.rt-wrap){
  display: block;
  margin: 0;
  line-height: 1.75;
  font-size: 140px;         /* 比正文略小一点 */
  color: var(--vp-c-text-2);
  letter-spacing: .2px;
}

/* 光标更柔和，减少“终端感” */
.lb-rotating :deep(.rt-caret){
  opacity: .45;
  margin-left: 2px;
}

/* 让广告条有一点“品牌色呼应”，但不抢标题 */
.lb-rotating :deep(.rt-text){
  background: linear-gradient(90deg, rgba(79,70,229,.9), rgba(236,72,153,.85));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}



</style>
