import fs from "fs";
import path from "path";
import yaml from "js-yaml";

function readYaml(p) {
  return yaml.load(fs.readFileSync(p, "utf-8"));
}
function writeYaml(p, obj) {
  const content = yaml.dump(obj, {
    lineWidth: 120,
    noRefs: true,
  });
  fs.writeFileSync(p, content, "utf-8");
}
function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}
function pad2(n) {
  return String(n).padStart(2, "0");
}

const [courseId] = process.argv.slice(2);
if (!courseId) {
  console.error("Usage: node lesson-builder/10-engine/expand_weeks_from_map.mjs <courseId>");
  process.exit(1);
}

const root = process.cwd();
const mapPath = path.join(
  root,
  "lesson-builder",
  "00-input",
  "weeks",
  courseId,
  "week-map.yaml"
);

if (!fs.existsSync(mapPath)) {
  console.error("❌ week-map.yaml not found:", mapPath);
  process.exit(1);
}

const weekMap = readYaml(mapPath);
const outWeeksDir = path.join(root, "lesson-builder", "00-input", "weeks", courseId);
ensureDir(outWeeksDir);

let created = 0;
let skipped = 0;

for (const item of weekMap.weeks || []) {
  const w = item.week;
  const wNo = pad2(w);
  const outPath = path.join(outWeeksDir, `week${wNo}.yaml`);

  if (fs.existsSync(outPath)) {
    skipped += 1;
    continue; // 不覆盖已存在的周文件（保护你已经写好的 week01/week02）
  }

  // 生成“最小可跑”的 week yaml 骨架（你后续再补 objectives/key_points/题目等）
  const obj = {
    week: {
      no: w,
      theme: item.theme || `Week ${w}`,
      chapters: item.chapters || [],
      objectives: [
        "（待补充）本周学习目标 1",
        "（待补充）本周学习目标 2",
      ],
      key_points: [
        "（待补充）本周重点 1",
        "（待补充）本周重点 2",
      ],
      schedule: [
        {
          type: "讲授",
          duration_min: 60,
          steps: ["（待补充）讲授内容要点"],
        },
        {
          type: "实操/练习",
          duration_min: 30,
          steps: ["（待补充）练习任务与步骤"],
        },
      ],
      homework: ["（待补充）本周作业 1"],
      ppt_decks: [
        {
          deck_no: 1,
          title: `W${wNo}-1｜${item.theme || `Week ${w}`}（上）`,
          review_quiz: { single: ["（待补充）"], multi: [], subjective: [] },
          lead_in_question: "（待补充）导入思考题",
          content_outline: ["（待补充）内容要点 1", "（待补充）内容要点 2"],
          in_class_quiz: {
            single: ["（待补充）"],
            multi: ["（待补充）"],
            subjective: ["（待补充）"],
          },
          summary_points: ["（待补充）总结要点 1"],
          after_class_homework: ["（待补充）作业 1"],
        },
        {
          deck_no: 2,
          title: `W${wNo}-2｜${item.theme || `Week ${w}`}（下）`,
          review_quiz: { single: ["（待补充）"], multi: [], subjective: [] },
          lead_in_question: "（待补充）导入思考题",
          content_outline: ["（待补充）内容要点 1", "（待补充）内容要点 2"],
          in_class_quiz: {
            single: ["（待补充）"],
            multi: ["（待补充）"],
            subjective: ["（待补充）"],
          },
          summary_points: ["（待补充）总结要点 1"],
          after_class_homework: ["（待补充）作业 1"],
        },
      ],
    },
  };

  writeYaml(outPath, obj);
  created += 1;
}

console.log("✅ expand done:", { created, skipped, weeks_total: (weekMap.weeks || []).length });
console.log("📁 weeks dir:", outWeeksDir);