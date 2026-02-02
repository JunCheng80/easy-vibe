import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import Handlebars from "handlebars";

function readYaml(p) {
  return yaml.load(fs.readFileSync(p, "utf-8"));
}
function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}
function stampDate() {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

/**
 * 从 courseYaml 推断课程 slug：
 * 例如 speech_appdev.dl.yaml -> speech_appdev
 */
function inferCourseSlug(courseYamlPath) {
  const base = path.basename(courseYamlPath);
  return base.split(".")[0];
}

/**
 * 从 lessonYaml 推断周次 md 文件名：
 * 例如 week01.yaml -> week01.md
 */
function inferWeekMd(lessonYamlPath) {
  const name = path.basename(lessonYamlPath, path.extname(lessonYamlPath));
  return `${name}.md`;
}

/**
 * 默认输出到 docs/zh-cn/lesson-plans/<courseSlug>/<week>.md
 * 注意：用 process.cwd() 当 repo 根目录（你是在 easy-vibe 根目录运行 node 的）
 */
function defaultOutMd(courseYamlPath, lessonYamlPath) {
  const repoRoot = process.cwd();
  const courseSlug = inferCourseSlug(courseYamlPath);
  const weekMd = inferWeekMd(lessonYamlPath);
  return path.join(repoRoot, "docs", "zh-cn", "lesson-plans", courseSlug, weekMd);
}

/**
 * 确保课程目录页存在（避免你 sidebar 点“智能语音处理及应用开发”404）
 * 若存在则不覆盖（尊重你手写内容）
 */
function ensureCourseIndex(courseYamlPath, courseObj) {
  const repoRoot = process.cwd();
  const courseSlug = inferCourseSlug(courseYamlPath);
  const humanTitle =
    courseObj?.course?.title ||
    courseObj?.course?.name ||
    courseObj?.course?.course_name ||
    courseSlug;

  const courseDir = path.join(repoRoot, "docs", "zh-cn", "lesson-plans", courseSlug);
  const indexPath = path.join(courseDir, "index.md");

  ensureDir(courseDir);

  // 扫描 week*.md
  const weeks = fs.existsSync(courseDir)
    ? fs.readdirSync(courseDir)
        .filter(f => /^week\d+\.md$/.test(f))
        .sort((a, b) => {
          const na = parseInt(a.match(/\d+/)[0], 10);
          const nb = parseInt(b.match(/\d+/)[0], 10);
          return na - nb;
        })
    : [];

  const weekLinks = weeks
    .map(f => {
      const name = f.replace(".md", "");
      return `- [${name}](./${name})`;
    })
    .join("\n");

  const content = `---
title: ${humanTitle}
---

# ${humanTitle}

${weekLinks || "_（尚未生成周次内容）_"}
`;

  fs.writeFileSync(indexPath, content, "utf-8");
  console.log("📘 Updated course index:", indexPath);
}


// CLI: node gen_lesson_plan.mjs <courseYaml> <lessonYaml> [outMd]
const [courseYaml, lessonYaml, outMdArg] = process.argv.slice(2);
if (!courseYaml || !lessonYaml) {
  console.error("Usage: node gen_lesson_plan.mjs <courseYaml> <lessonYaml> [outMd]");
  process.exit(1);
}

// ✅ 工厂容器固定路径
const LB = "lesson-builder";
const templatePath = path.resolve(LB, "20-templates", "lesson_plan.md");
const stamp = stampDate();
const archiveDir = path.resolve(LB, "30-outputs", stamp);

const courseObj = readYaml(courseYaml);
const lessonObj = readYaml(lessonYaml);

const template = fs.readFileSync(templatePath, "utf-8");
const compile = Handlebars.compile(template);
const md = compile({ course: courseObj.course, lesson: lessonObj.lesson });

// ✅ 站点输出路径：优先用用户传参，否则自动推断
const outMd = outMdArg ? path.resolve(outMdArg) : defaultOutMd(courseYaml, lessonYaml);

// （推荐）确保课程目录页存在，避免 sidebar 404
ensureCourseIndex(courseYaml, courseObj);

// 1) 写到 docs（站点展示）
ensureDir(path.dirname(outMd));
fs.writeFileSync(outMd, md, "utf-8");

// 2) 归档到 outputs（工厂归档）
ensureDir(archiveDir);
const archived = path.join(archiveDir, path.basename(outMd));
fs.writeFileSync(archived, md, "utf-8");

console.log("✅ Generated:", outMd);
console.log("📦 Archived :", archived);
