---
title: {{lesson.title}}
course: {{course.name}}
week: {{lesson.week}}
---

# {{lesson.title}}

## 1. 课时信息
- 课程：{{course.name}}
- 周次：第 {{lesson.week}} 周
- 时长：{{lesson.duration_minutes}} 分钟

## 2. 教学目标
{{#each lesson.objectives}}
- {{this}}
{{/each}}

## 3. 教学流程
{{#each lesson.agenda}}
### {{this.name}}（{{this.minutes}}分钟）
- 要点：{{this.notes}}
{{/each}}

## 4. 课后作业
- 阅读/预习：语音AI应用案例各找 1 个（ASR + TTS）
- 思考：选择一个语音需求，写出“输入→处理→输出”的流水线草图
