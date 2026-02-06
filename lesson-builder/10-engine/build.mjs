import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import Handlebars from "handlebars";

/** -----------------------------
 * Helpers
 * ---------------------------- */
function rmDirSafe(dir) {
  if (!dir) return;
  if (!fs.existsSync(dir)) return;

  // 安全保护：只允许删 lesson-builder/30-outputs 或 docs/zh-cn/lesson-plans 下的目录
  const normalized = dir.replace(/\\/g, "/");
  const ok =
    normalized.includes("/lesson-builder/30-outputs/") ||
    normalized.includes("/docs/zh-cn/lesson-plans/");

  if (!ok) {
    throw new Error(`Refuse to delete unsafe dir: ${dir}`);
  }

  fs.rmSync(dir, { recursive: true, force: true });
}

function cleanTermDirs({ outDir, docsOutDir }) {
  rmDirSafe(outDir);
  rmDirSafe(docsOutDir);
}

function readYaml(p) {
  return yaml.load(fs.readFileSync(p, "utf-8"));
}
function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}
function loadTemplate(p) {
  return Handlebars.compile(fs.readFileSync(p, "utf-8"));
}
function pad2(n) {
  return String(n).padStart(2, "0");
}
function nowStamp() {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  const hh = String(d.getHours()).padStart(2, "0");
  const mm = String(d.getMinutes()).padStart(2, "0");
  return `${y}-${m}-${day} ${hh}:${mm}`;
}
function safeGet(obj, pathStr, fallback) {
  try {
    const parts = pathStr.split(".");
    let cur = obj;
    for (const k of parts) {
      if (cur == null) return fallback;
      cur = cur[k];
    }
    return cur ?? fallback;
  } catch {
    return fallback;
  }
}
function copyDirFlat(srcDir, dstDir) {
  ensureDir(dstDir);
  const files = fs
    .readdirSync(srcDir)
    .filter((f) => f.endsWith(".md") || f.endsWith(".json"));
  for (const f of files) {
    fs.copyFileSync(path.join(srcDir, f), path.join(dstDir, f));
  }
  return files;
}

/** -----------------------------
 * Handlebars helpers
 * ---------------------------- */
Handlebars.registerHelper("join", (arr, sep) => (arr || []).join(sep || "、"));
Handlebars.registerHelper("first", (arr) => (arr && arr.length ? arr[0] : ""));
Handlebars.registerHelper("add", (a, b) => Number(a) + Number(b)); // for Slide numbering

/** -----------------------------
 * CLI args
 * ---------------------------- */
const args = process.argv.slice(2);
const courseId = args[0];
const term = args[1];
const CLEAN = args.includes("--clean");

if (!courseId || !term) {
  console.error("Usage: node lesson-builder/10-engine/build.mjs <courseId> <term> [--clean]");
  process.exit(1);
}

if (!courseId || !term) {
  console.error("Usage: node lesson-builder/10-engine/build.mjs <courseId> <term>");
  process.exit(1);
}

const root = process.cwd();

/** -----------------------------
 * Load rules (00-rules)
 * ---------------------------- */
const qualityPolicyPath = path.join(
  root,
  "lesson-builder",
  "00-rules",
  "policies",
  "quality_policy.yaml"
);
const pptPolicyPath = path.join(
  root,
  "lesson-builder",
  "00-rules",
  "policies",
  "ppt_policy.yaml"
);

const rules = fs.existsSync(qualityPolicyPath) ? readYaml(qualityPolicyPath) : {};
const pptRules = fs.existsSync(pptPolicyPath) ? readYaml(pptPolicyPath) : {};

const qualityPolicy = rules?.quality_policy || {};
const pptPolicy = pptRules?.ppt_policy || {};
const defaultDeckTpl = pptPolicy?.default_deck || {};

/** -----------------------------
 * Resolve course yaml
 * ---------------------------- */
function resolveCourseYaml(courseId, term) {
  const p1 = path.join(
    root,
    "lesson-builder",
    "00-input",
    "courses",
    `${courseId}.${term}.course.yaml`
  );
  if (fs.existsSync(p1)) return p1;

  const coursesDir = path.join(root, "lesson-builder", "00-input", "courses");
  const candidates = fs
    .readdirSync(coursesDir)
    .filter((f) => f.startsWith(`${courseId}.`) && f.endsWith(`.${term}.course.yaml`));
  if (candidates.length > 0) return path.join(coursesDir, candidates[0]);
  return null;
}

const courseYaml = resolveCourseYaml(courseId, term);
if (!courseYaml) {
  console.error("❌ course yaml not found. Expected one of:");
  console.error(`  - lesson-builder/00-input/courses/${courseId}.${term}.course.yaml`);
  console.error(`  - lesson-builder/00-input/courses/${courseId}.*.${term}.course.yaml`);
  process.exit(1);
}

const courseObj = readYaml(courseYaml);

/** -----------------------------
 * Directories
 * ---------------------------- */
const weeksDir = path.join(root, "lesson-builder", "00-input", "weeks", courseId);
if (!fs.existsSync(weeksDir)) {
  console.error("❌ weeks dir not found:", weeksDir);
  process.exit(1);
}

const outDir = path.join(root, "lesson-builder/30-outputs", courseId, term);

// docs 归档目录（提前算出来，方便 clean）
const docsOutDir = path.join(root, "docs", "zh-cn", "lesson-plans", courseId, term);

if (CLEAN) {
  console.log("🧹 --clean enabled. Removing old outputs:");
  console.log("  -", outDir);
  console.log("  -", docsOutDir);
  cleanTermDirs({ outDir, docsOutDir });
}

ensureDir(outDir);


const tplDir = path.join(root, "lesson-builder", "20-templates");
const tplSyllabus = loadTemplate(path.join(tplDir, "syllabus.md.hbs"));
const tplCalendar = loadTemplate(path.join(tplDir, "calendar.md.hbs"));
const tplLessonPlan = loadTemplate(path.join(tplDir, "lesson_plan.md.hbs"));
const tplPptDeck = loadTemplate(path.join(tplDir, "ppt_deck.md.hbs"));

/** -----------------------------
 * Derived params from rules
 * ---------------------------- */
const PLACEHOLDER_PATTERNS =
  qualityPolicy.placeholder_keywords ?? ["（待补充）", "TODO", "TBD", "待完善"];

const ppt_per_week_min =
  courseObj?.course?.ppt_per_week_min ?? pptPolicy.ppt_per_week_min ?? 2;

const deck_duration_min = pptPolicy.deck_duration_min ?? 90;

/** -----------------------------
 * Load weeks
 * ---------------------------- */
const weekFiles = fs
  .readdirSync(weeksDir)
  .filter((f) => /^week\d+\.yaml$/.test(f))
  .sort();

const weeks = weekFiles.map((f) => ({
  file: f,
  abs: path.join(weeksDir, f),
  data: readYaml(path.join(weeksDir, f)),
}));

/** -----------------------------
 * Placeholder scan
 * ---------------------------- */
function textHasPlaceholder(text) {
  if (!text) return false;
  return PLACEHOLDER_PATTERNS.some((p) => String(text).includes(p));
}

function scanObject(obj, basePath) {
  const hits = [];
  function walk(node, pth) {
    if (node === null || node === undefined) return;
    if (typeof node === "string" || typeof node === "number" || typeof node === "boolean") {
      const s = String(node);
      if (textHasPlaceholder(s)) hits.push({ path: pth, value: s });
      return;
    }
    if (Array.isArray(node)) {
      node.forEach((x, i) => walk(x, `${pth}[${i}]`));
      return;
    }
    if (typeof node === "object") {
      Object.entries(node).forEach(([k, v]) => walk(v, pth ? `${pth}.${k}` : k));
    }
  }
  walk(obj, basePath || "");
  return hits;
}

/** -----------------------------
 * Output writer + logs
 * ---------------------------- */
const generatedFiles = [];
const autofillLog = [];

function writeOut(rel, content) {
  const p = path.join(outDir, rel);
  fs.writeFileSync(p, content, "utf-8");
  generatedFiles.push(rel);
  return p;
}

/** -----------------------------
 * 1) Generate syllabus / calendar
 * ---------------------------- */
writeOut("syllabus.md", tplSyllabus({ course: courseObj.course, ppt: pptPolicy }));
writeOut(
  "calendar.md",
  tplCalendar({ course: courseObj.course, weeks: weeks.map((w) => w.data), ppt: pptPolicy })
);

/** -----------------------------
 * 2) Generate weekly lesson plan + ppt scripts
 * ---------------------------- */
for (const w of weeks) {
  const weekObj = w.data.week;
  const wNo = pad2(weekObj.no);

  writeOut(
    `week${wNo}.lesson_plan.md`,
    tplLessonPlan({ course: courseObj.course, week: weekObj, ppt: pptPolicy })
  );

  const originalLen = (weekObj.ppt_decks || []).length;
  const decks = (weekObj.ppt_decks || []).slice();

  // record autofill summary (only once per week)
  if (originalLen < ppt_per_week_min) {
    autofillLog.push({
      week: weekObj.no,
      existed: originalLen,
      required: ppt_per_week_min,
      filled: ppt_per_week_min - originalLen,
    });
  }

  // auto-fill decks to minimum
  while (decks.length < ppt_per_week_min) {
    const nextNo = decks.length + 1;

    decks.push({
      deck_no: nextNo,
      title: `W${wNo}-${nextNo}｜${weekObj.theme || "本周主题"}${
        defaultDeckTpl.title_suffix || "（自动补齐）"
      }`,
      review_quiz:
        defaultDeckTpl.review_quiz || { single: ["（待补充）"], multi: [], subjective: [] },
      lead_in_question: defaultDeckTpl.lead_in_question || "（待补充）导入思考题",
      content_outline:
        defaultDeckTpl.content_outline || ["（待补充）要点1", "（待补充）要点2", "（待补充）要点3"],
      in_class_quiz:
        defaultDeckTpl.in_class_quiz || {
          single: ["（待补充）单选题"],
          multi: ["（待补充）多选题"],
          subjective: ["（待补充）主观题"],
        },
      summary_points: defaultDeckTpl.summary_points || ["（待补充）总结要点"],
      after_class_homework: defaultDeckTpl.after_class_homework || ["（待补充）课后作业"],
    });
  }

  // render decks
  for (const deck of decks) {
    const dNo = pad2(deck.deck_no);
    writeOut(
      `week${wNo}.ppt${dNo}.md`,
      tplPptDeck({
        course: courseObj.course,
        week: weekObj,
        deck,
        ppt: { ...pptPolicy, deck_duration_min }, // pass policy to template
      })
    );
  }
}

/** -----------------------------
 * 3) manifest.json
 * ---------------------------- */
const manifest = {
  generated_at: nowStamp(),
  course_id: courseId,
  term,
  course_yaml: path.relative(root, courseYaml).replace(/\\/g, "/"),
  rules: {
    quality_policy: path.relative(root, qualityPolicyPath).replace(/\\/g, "/"),
    ppt_policy: path.relative(root, pptPolicyPath).replace(/\\/g, "/"),
  },
  weeks_dir: path.relative(root, weeksDir).replace(/\\/g, "/"),
  weeks_count: weeks.length,
  weeks_files: weeks.map((w) => w.file),
  outputs_dir: path.relative(root, outDir).replace(/\\/g, "/"),
  outputs: [...generatedFiles].sort(),
  ppt_per_week_min,
  deck_duration_min,
};
fs.writeFileSync(path.join(outDir, "manifest.json"), JSON.stringify(manifest, null, 2), "utf-8");
generatedFiles.push("manifest.json");

/** -----------------------------
 * 4) placeholder scan: input + output
 * ---------------------------- */
const todo = [];

// scan input yaml
for (const w of weeks) {
  const hits = scanObject(w.data, "");
  if (hits.length) {
    todo.push({
      type: "input_week_yaml",
      file: path.relative(root, w.abs).replace(/\\/g, "/"),
      hits,
    });
  }
}

// scan output md
for (const rel of generatedFiles.filter((x) => x.endsWith(".md"))) {
  const abs = path.join(outDir, rel);
  const content = fs.readFileSync(abs, "utf-8");
  if (textHasPlaceholder(content)) {
    const lines = content.split(/\r?\n/);
    const hitLines = [];
    lines.forEach((line, idx) => {
      if (textHasPlaceholder(line)) hitLines.push({ line_no: idx + 1, text: line.trim() });
    });
    todo.push({
      type: "output_md",
      file: path.relative(root, abs).replace(/\\/g, "/"),
      hits: hitLines,
    });
  }
}

/** -----------------------------
 * 5) todo_report.md (+auto-filled)
 * ---------------------------- */
let report = `# 待完善清单（Placeholder Report）\n\n`;
report += `- 生成时间：${manifest.generated_at}\n`;
report += `- 课程：${courseId}｜学期：${term}\n`;
report += `- 每周最少PPT套数：${ppt_per_week_min}\n`;
report += `- PPT建议时长：${deck_duration_min} 分钟/套\n`;
report += `- 占位符关键字：${PLACEHOLDER_PATTERNS.join(" / ")}\n\n`;

if (autofillLog.length) {
  report += `## auto_filled_decks（自动补齐记录）\n`;
  for (const x of autofillLog) {
    report += `- week${pad2(x.week)}: existed=${x.existed}, required=${x.required}, filled=+${x.filled}\n`;
  }
  report += `\n`;
}

if (todo.length === 0) {
  report += `✅ 未发现占位符，内容已趋于完整。\n`;
} else {
  report += `共发现 **${todo.length}** 处包含占位符的文件（输入/输出）。\n\n`;
  for (const item of todo) {
    report += `## ${item.type}\n`;
    report += `- 文件：${item.file}\n`;
    report += `- 命中：${item.hits.length}\n\n`;

    const sample = item.hits.slice(0, 20);
    for (const h of sample) {
      if (item.type === "input_week_yaml") {
        report += `- \`${h.path}\`: ${h.value}\n`;
      } else {
        report += `- L${h.line_no}: ${h.text}\n`;
      }
    }
    if (item.hits.length > 20) report += `- …（还有 ${item.hits.length - 20} 条未展示）\n`;
    report += `\n`;
  }
}

fs.writeFileSync(path.join(outDir, "todo_report.md"), report, "utf-8");
generatedFiles.push("todo_report.md");

/** -----------------------------
 * C) Archive to docs/zh-cn/lesson-plans/...
 * ---------------------------- */
const archived = copyDirFlat(outDir, docsOutDir);

// Generate an index.md in docsOutDir
const mdList = archived.filter((f) => f.endsWith(".md") && f !== "index.md").sort();
let indexMd = `---\ntitle: ${courseId}｜${term}｜备课产出\n---\n\n`;
indexMd += `# ${courseId}｜${term}｜备课产出\n\n`;
indexMd += `- syllabus: [syllabus](./syllabus)\n`;
indexMd += `- calendar: [calendar](./calendar)\n`;
indexMd += `- todo_report: [todo_report](./todo_report)\n\n`;
indexMd += `## Weeks\n\n`;
for (const f of mdList) {
  if (f.startsWith("week")) indexMd += `- [${f.replace(".md", "")}](./${f.replace(".md", "")})\n`;
}
fs.writeFileSync(path.join(docsOutDir, "index.md"), indexMd, "utf-8");

/** -----------------------------
 * Terminal summary
 * ---------------------------- */
console.log("✅ generated:", outDir);
console.log("  - syllabus.md");
console.log("  - calendar.md");
console.log(`  - weeks: ${weeks.length}`);
console.log("  - manifest.json");
console.log("  - todo_report.md");

if (autofillLog.length) console.log("⚠️ auto-filled decks:", autofillLog);

console.log("📦 archived to:", docsOutDir);
console.log("  - files:", archived.length);
console.log("  - index.md: generated");