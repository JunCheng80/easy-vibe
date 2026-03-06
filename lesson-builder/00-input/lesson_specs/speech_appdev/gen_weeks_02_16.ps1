# gen_weeks_02_16.ps1
# Run at repo root: E:\Projects\easy-vibe
# Generates week02~week16 YAML into lesson-builder/00-input/lesson_specs/speech_appdev/

$ErrorActionPreference = "Stop"

$baseDir = Join-Path (Get-Location) "lesson-builder/00-input/lesson_specs/speech_appdev/yaml"
New-Item -ItemType Directory -Force -Path $baseDir | Out-Null

function Write-Utf8NoBom([string]$path, [string]$content) {
  # PowerShell 7+ supports -Encoding utf8NoBOM
  # On Windows PowerShell 5.1, we use .NET UTF8Encoding(false)
  if ($PSVersionTable.PSVersion.Major -ge 7) {
    Set-Content -Path $path -Value $content -Encoding utf8NoBOM
  } else {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)    
}
}

function Add-Week01CommentSkeleton([string]$yamlText) {
  # 按“week01.yaml 的注释骨架”给 week02~week16 自动补齐注释
  # 原则：如果目标注释已存在，则不重复插入

  function Ensure-CommentBeforeKey([string]$text, [string]$keyRegex, [string]$commentLine) {
    if ($text -match [regex]::Escape($commentLine)) { return $text }
    # 在目标 key 前插入注释（保持两空格缩进风格）
    return [regex]::Replace(
      $text,
      "(?m)^(  $keyRegex\s*:)",
      "$commentLine`n`$1",
      1
    )
  }

  $yamlText = Ensure-CommentBeforeKey $yamlText "student_analysis" "  # 二、学情分析（200-300字左右）"
  $yamlText = Ensure-CommentBeforeKey $yamlText "content_analysis" "  # 三、教学内容分析"
  $yamlText = Ensure-CommentBeforeKey $yamlText "objectives" "  # 四、教学目标（四类目标）"
  $yamlText = Ensure-CommentBeforeKey $yamlText "process" "  # 五、课程教学过程设计（数组，驱动表格行）"
  $yamlText = Ensure-CommentBeforeKey $yamlText "homework" "  # 六、课后作业"
  $yamlText = Ensure-CommentBeforeKey $yamlText "reflection" "  # 七、教学反思（20-30字左右）"
  $yamlText = Ensure-CommentBeforeKey $yamlText "references" "  # 八、参考资料（2-3条）"

  return $yamlText
}


# ---------------- week02 ----------------
$week02 = @"
lesson:
  title: "语音信号基础与采样量化（采样率/位深/奈奎斯特）"
  chapter_title: "语音信号基础：采样、量化与波形理解"
  week_no: 2
  hours: 2

  student_analysis: >
    学生对“连续/离散”的概念停留在数学层面，对语音波形的采样与量化如何影响音质、文件大小和模型输入缺少直观体验。
    本周将通过可视化与听感对比，建立“采样率/位深/频谱”与任务性能的联系。

  content_analysis:
    basic: "语音信号的时域/频域直观；采样定理与奈奎斯特；量化与位深；常见音频格式与参数。"
    key_points: "采样率与可恢复频率范围；量化误差与信噪比；参数选择对ASR/TTS输入的影响。"
    difficult_points: "从听感/频谱理解采样不足与混叠；量化噪声的来源与表现。"

  objectives:
    value: "建立对数据质量负责的意识，理解参数选择的工程意义。"
    knowledge: "掌握采样率、位深、混叠、量化误差等基本概念与规律。"
    ability: "能为一个应用场景选择合理音频参数，并解释原因。"
    quality: "培养实验对比与证据表达能力，形成规范记录习惯。"

  process:
    - step: 1
      teach_content: "复习上周流水线：数据质量在流水线的位置"
      teacher_action: "回顾关键点，给出本周任务与产出要求"
      student_action: "回忆并回答：采样率在哪一步起作用？"
      method: "讲授法"
      time: "10分钟"
    - step: 2
      teach_content: "采样定理与混叠：波形与频谱可视化"
      teacher_action: "演示不同采样率下的波形/频谱变化"
      student_action: "观察对比并记录结论"
      method: "讲授法、演示法"
      time: "30分钟"
    - step: 3
      teach_content: "量化与位深：量化噪声与听感对比"
      teacher_action: "讲解位深与量化误差，播放对比样例"
      student_action: "分组讨论：哪个参数更影响听感？为什么？"
      method: "讨论法、启发式"
      time: "30分钟"
    - step: 4
      teach_content: "课堂小练习：为ASR任务选择采样率/位深并说明"
      teacher_action: "给出场景与约束（存储/带宽/实时性），点评方案"
      student_action: "小组提交参数选择与理由"
      method: "任务驱动"
      time: "20分钟"

  homework: "完成一次音频参数对比实验（至少3种采样率或位深），写出结论：参数变化→听感/频谱→对任务的影响猜测。"
  reflection: "演示与听感对比非常有效，但需控制数学推导深度，避免过载。"
  references:
    - "数字信号处理/语音信号处理教材：采样定理与量化章节"
    - "常见音频格式与采样率说明文档（WAV/PCM等）"
    - "开源音频处理工具（如librosa）入门文档"
"@
$week02 = Add-Week01CommentSkeleton $week02
Write-Utf8NoBom (Join-Path $baseDir "week02.yaml") $week02

# ---------------- week03 ----------------
$week03 = @"
lesson:
  title: "语音预处理：端点检测、降噪与增益"
  chapter_title: "语音预处理：清洗、分段与增强"
  week_no: 3
  hours: 2
  student_analysis: >
    学生对“脏数据会毁模型”有直觉，但缺少预处理可操作方法（切分、去静音、降噪等）。
    本周通过示例让学生把“预处理”变成可以复现的步骤。
  content_analysis:
    basic: "端点检测/静音处理；简单降噪；归一化与增益；预处理在ASR/TTS中的位置。"
    key_points: "预处理目标与副作用；可复现的处理流程；评估处理前后的差异。"
    difficult_points: "避免过度处理导致信息损失；不同场景选择不同策略。"
  objectives:
    value: "形成数据治理与工程复现意识。"
    knowledge: "理解端点检测、降噪、增益等预处理概念与用途。"
    ability: "能设计并复现实验：处理前后对比（波形/频谱/听感/指标）。"
    quality: "培养小步验证与版本记录习惯。"
  process:
    - step: 1
      teach_content: "引入：为什么预处理决定上限"
      teacher_action: "展示‘未处理 vs 处理后’对比"
      student_action: "观察并说出差异"
      method: "演示法"
      time: "15分钟"
    - step: 2
      teach_content: "端点检测与切分"
      teacher_action: "讲解方法与参数，给出示例"
      student_action: "跟做并记录参数"
      method: "讲授法、实操"
      time: "25分钟"
    - step: 3
      teach_content: "简单降噪与增益/归一化"
      teacher_action: "讲解策略与副作用"
      student_action: "对比处理效果，写结论"
      method: "启发式"
      time: "30分钟"
    - step: 4
      teach_content: "小练习：为一个场景设计预处理流水线"
      teacher_action: "点评并给改进建议"
      student_action: "小组提交方案"
      method: "任务驱动、讨论法"
      time: "20分钟"
  homework: "完成一个预处理流水线（端点检测+降噪/归一化），输出处理前后对比截图与结论。"
  reflection: "实操时间要留足；参数记录模板要提前发。"
  references:
    - "语音预处理基础文章/教材章节"
    - "librosa/pyannote等工具的预处理示例"
    - "开源ASR项目的数据处理脚本参考"
"@
$week03 = Add-Week01CommentSkeleton $week03
Write-Utf8NoBom (Join-Path $baseDir "week03.yaml") $week03

# ---------------- week04 ----------------
$week04 = @"
lesson:
  title: "语音特征入门：STFT与梅尔谱"
  chapter_title: "特征工程：从波形到谱图"
  week_no: 4
  hours: 2
  student_analysis: >
    学生对“谱图像图片”很感兴趣，但容易停留在表面，不理解参数（窗长/步长）含义。
  content_analysis:
    basic: "STFT；窗函数；梅尔滤波器组；Mel Spectrogram直观解释。"
    key_points: "窗长/步长与时间-频率分辨率权衡；Mel谱与听觉相关性。"
    difficult_points: "参数选择逻辑；谱图细节与任务性能的关联。"
  objectives:
    value: "建立从数据到表征的工程思维。"
    knowledge: "理解STFT与Mel谱的生成机制与参数含义。"
    ability: "能生成并解释不同参数下的谱图差异。"
    quality: "形成‘对比实验+结论’的表达习惯。"
  process:
    - step: 1
      teach_content: "导入：为什么要做特征"
      teacher_action: "用案例解释‘表征决定模型输入质量’"
      student_action: "回答：波形 vs 谱图区别"
      method: "讲授法"
      time: "10分钟"
    - step: 2
      teach_content: "STFT与窗长/步长"
      teacher_action: "推导不深讲直观，演示参数效果"
      student_action: "记录参数对比结论"
      method: "演示法"
      time: "30分钟"
    - step: 3
      teach_content: "Mel谱与听觉尺度"
      teacher_action: "讲解Mel滤波器组与直观意义"
      student_action: "分组讨论：为何对语音更友好"
      method: "讨论法"
      time: "30分钟"
    - step: 4
      teach_content: "练习：生成2种Mel谱并比较"
      teacher_action: "点评差异并给建议"
      student_action: "提交截图与一句话结论"
      method: "任务驱动"
      time: "20分钟"
  homework: "生成并保存3组不同参数的Mel谱图，写出参数变化→谱图变化→可能影响。"
  reflection: "避免陷入数学细节；用可视化和对比结论更有效。"
  references:
    - "STFT与Mel谱基础教程"
    - "librosa.feature.melspectrogram 文档"
    - "ASR特征工程讲义/博客"
"@
$week04 = Add-Week01CommentSkeleton $week04
Write-Utf8NoBom (Join-Path $baseDir "week04.yaml") $week04

# ---------------- week05 ----------------
$week05 = @"
lesson:
  title: "MFCC特征与传统ASR特征链"
  chapter_title: "经典特征：MFCC与语音识别传统管线"
  week_no: 5
  hours: 2
  student_analysis: >
    学生对MFCC听过但不理解每一步为何存在；容易把MFCC当黑盒。
  content_analysis:
    basic: "MFCC步骤：Mel谱→log→DCT；一阶二阶差分；CMVN。"
    key_points: "MFCC每一步的目的；与Mel谱的关系；适用场景。"
    difficult_points: "理解DCT与‘去相关’的直观意义；特征选择依据。"
  objectives:
    value: "理解‘经典方法也有价值’，培养技术演进视角。"
    knowledge: "掌握MFCC构成与常用增强（delta/CMVN）。"
    ability: "能实现或调用MFCC提取并解释输出。"
    quality: "培养结构化拆解与复现能力。"
  process:
    - step: 1
      teach_content: "回顾Mel谱与参数"
      teacher_action: "快速复盘+提出MFCC问题"
      student_action: "回答：Mel谱还缺什么？"
      method: "提问法"
      time: "10分钟"
    - step: 2
      teach_content: "MFCC全流程拆解"
      teacher_action: "逐步讲解每一步目的"
      student_action: "画出MFCC流程图"
      method: "讲授法"
      time: "30分钟"
    - step: 3
      teach_content: "delta/CMVN与稳定性"
      teacher_action: "演示加入/不加入的效果差异"
      student_action: "总结：稳定性来自哪里"
      method: "演示法、讨论法"
      time: "30分钟"
    - step: 4
      teach_content: "练习：提取MFCC并解释维度"
      teacher_action: "点评与纠错"
      student_action: "提交输出维度与解释"
      method: "任务驱动"
      time: "20分钟"
  homework: "完成MFCC特征提取（含delta/CMVN任选），写出每一步的目的说明。"
  reflection: "流程图任务很关键；要留时间让学生真正画出来。"
  references:
    - "MFCC原理入门资料"
    - "语音识别传统特征链资料"
    - "librosa.feature.mfcc 文档"
"@
$week05 = Add-Week01CommentSkeleton $week05
Write-Utf8NoBom (Join-Path $baseDir "week05.yaml") $week05

# ---------------- week06 ----------------
$week06 = @"
lesson:
  title: "ASR基础：CTC思想与解码直觉"
  chapter_title: "语音识别入门：CTC与解码"
  week_no: 6
  hours: 2
  student_analysis: >
    学生对“把语音变文字”感兴趣，但对对齐问题与CTC的存在理由不清楚。
  content_analysis:
    basic: "ASR任务定义；对齐困难；CTC基本思想；简单解码（贪心/beam）。"
    key_points: "CTC如何解决长度不一致；blank与重复折叠；WER含义。"
    difficult_points: "把概率序列转成文本的过程理解；WER计算。"
  objectives:
    value: "建立对模型输出与评估的客观认知。"
    knowledge: "理解CTC核心机制与解码方式。"
    ability: "能解释一段CTC输出如何变成文本，并计算简单WER。"
    quality: "培养从输出到指标的闭环意识。"
  process:
    - step: 1
      teach_content: "ASR对齐问题引入"
      teacher_action: "用例子展示‘长度不一致’"
      student_action: "回答：难点在哪里"
      method: "启发式"
      time: "15分钟"
    - step: 2
      teach_content: "CTC机制讲解"
      teacher_action: "讲解blank/折叠规则"
      student_action: "跟做例题：序列→文本"
      method: "讲授法"
      time: "30分钟"
    - step: 3
      teach_content: "贪心与beam解码直觉"
      teacher_action: "演示两种解码差异"
      student_action: "讨论：何时需要beam"
      method: "讨论法"
      time: "25分钟"
    - step: 4
      teach_content: "WER入门与小练习"
      teacher_action: "讲解WER定义与计算"
      student_action: "完成1道WER计算题"
      method: "练习法"
      time: "20分钟"
  homework: "找一个ASR模型（或文章），写出：输出形式、解码方式、评估指标。"
  reflection: "例题和可视化是关键；CTC部分不宜过深推导。"
  references:
    - "CTC入门讲解资料"
    - "WER定义与示例"
    - "开源ASR项目推理/解码代码参考"
"@
$week06 = Add-Week01CommentSkeleton $week06
Write-Utf8NoBom (Join-Path $baseDir "week06.yaml") $week06

# ---------------- week07 ----------------
$week07 = @"
lesson:
  title: "ASR评估与数据集：WER/CER与常见语料"
  chapter_title: "ASR评估与数据：指标、语料与误差分析"
  week_no: 7
  hours: 2
  student_analysis: >
    学生能背指标名，但不会做误差分析，不清楚数据集差异会导致模型结论不可比。
  content_analysis:
    basic: "WER/CER；测试集划分；口音/噪声/领域差异；误差类型分析。"
    key_points: "指标正确计算；可比性与基线；误差归因。"
    difficult_points: "把错误分类型并提出改进方向。"
  objectives:
    value: "培养科学评估与诚实报告意识。"
    knowledge: "掌握WER/CER与数据集划分基本原则。"
    ability: "能做一份简要误差分析报告并提出改进建议。"
    quality: "形成可复现实验与严谨表达习惯。"
  process:
    - step: 1
      teach_content: "指标复盘：WER/CER"
      teacher_action: "给1-2个计算例子"
      student_action: "完成快速计算"
      method: "练习法"
      time: "15分钟"
    - step: 2
      teach_content: "数据集与可比性"
      teacher_action: "讲解分布差异、切分原则"
      student_action: "讨论：为何不能跨数据集直接比"
      method: "讨论法"
      time: "30分钟"
    - step: 3
      teach_content: "误差分析方法"
      teacher_action: "给出分类模板（插入/删除/替换等）"
      student_action: "按模板分析一组错误样例"
      method: "案例分析"
      time: "30分钟"
    - step: 4
      teach_content: "小结：从误差到改进"
      teacher_action: "示范‘问题→原因→策略’"
      student_action: "提交1条改进建议"
      method: "任务驱动"
      time: "15分钟"
  homework: "选一个ASR输出结果（或样例），完成误差分类+两条可执行改进建议。"
  reflection: "误差分析模板要标准化，方便后续周复用。"
  references:
    - "WER/CER指标资料"
    - "语音数据集介绍文档"
    - "错误分析与实验报告写作参考"
"@
$week07 = Add-Week01CommentSkeleton $week07
Write-Utf8NoBom (Join-Path $baseDir "week07.yaml") $week07

# ---------------- week08 ----------------
$week08 = @"
lesson:
  title: "TTS入门：从文本到语音的基本结构"
  chapter_title: "语音合成基础：TTS任务与评估"
  week_no: 8
  hours: 2
  student_analysis: >
    学生对TTS应用熟悉，但对MOS、音色与韵律的影响因素理解不足。
  content_analysis:
    basic: "TTS任务拆解；音色/韵律；常见评估MOS；数据与标注概念。"
    key_points: "TTS输出质量维度（清晰度/自然度/音色一致）；MOS含义。"
    difficult_points: "如何把主观质量拆成可操作的改进点。"
  objectives:
    value: "理解生成内容的质量标准与伦理边界。"
    knowledge: "掌握TTS任务构成与MOS评价基本概念。"
    ability: "能描述影响TTS质量的关键因素并提出改进策略。"
    quality: "培养对主观评测与客观证据的平衡意识。"
  process:
    - step: 1
      teach_content: "引入：TTS产品案例与质量维度"
      teacher_action: "播放不同质量样例"
      student_action: "给出主观评价理由"
      method: "演示法"
      time: "15分钟"
    - step: 2
      teach_content: "TTS任务拆解"
      teacher_action: "用流水线视角拆解模块"
      student_action: "画出TTS流水线"
      method: "讲授法"
      time: "30分钟"
    - step: 3
      teach_content: "MOS与评估流程"
      teacher_action: "讲解主观评测流程与注意事项"
      student_action: "讨论：如何降低主观偏差"
      method: "讨论法"
      time: "25分钟"
    - step: 4
      teach_content: "练习：为一段TTS输出写‘改进建议’"
      teacher_action: "点评建议是否可执行"
      student_action: "提交2条建议"
      method: "任务驱动"
      time: "20分钟"
  homework: "收集2个TTS样例并按质量维度评价，给出改进点。"
  reflection: "主观评测要有统一维度表，否则讨论会发散。"
  references:
    - "TTS入门资料（任务与流水线）"
    - "MOS评测流程说明"
    - "开源TTS项目文档"
"@
$week08 = Add-Week01CommentSkeleton $week08
Write-Utf8NoBom (Join-Path $baseDir "week08.yaml") $week08

# ---------------- week09 ----------------
$week09 = @"
lesson:
  title: "说话人识别：验证与识别的区别"
  chapter_title: "说话人相关任务：SID/SV与应用"
  week_no: 9
  hours: 2
  student_analysis: >
    学生容易把“识别”和“验证”混淆，对嵌入向量与相似度的直观意义不足。
  content_analysis:
    basic: "SID vs SV；嵌入向量；相似度（cosine）；应用场景。"
    key_points: "任务定义差异；阈值与误报漏报；数据与隐私。"
    difficult_points: "阈值选择与业务权衡。"
  objectives:
    value: "树立隐私与合规意识。"
    knowledge: "掌握SID/SV概念与相似度判断机制。"
    ability: "能解释阈值影响，并做简单ROC/权衡讨论。"
    quality: "培养指标与业务目标对齐意识。"
  process:
    - step: 1
      teach_content: "SID与SV概念辨析"
      teacher_action: "举例对比两类任务"
      student_action: "用自己的话复述差异"
      method: "讲授法"
      time: "15分钟"
    - step: 2
      teach_content: "嵌入向量与相似度直觉"
      teacher_action: "展示向量相似度判断例子"
      student_action: "完成一次阈值判断练习"
      method: "练习法"
      time: "25分钟"
    - step: 3
      teach_content: "误报/漏报与阈值选择"
      teacher_action: "讲解业务权衡"
      student_action: "小组讨论：门禁 vs 银行"
      method: "讨论法"
      time: "30分钟"
    - step: 4
      teach_content: "案例：说话人验证系统流程"
      teacher_action: "串联流水线"
      student_action: "提交流程图"
      method: "任务驱动"
      time: "20分钟"
  homework: "选择一个说话人场景，写出阈值权衡与风险点。"
  reflection: "隐私合规要点要讲透，避免只谈技术。"
  references:
    - "说话人识别/验证入门资料"
    - "相似度与阈值选择说明"
    - "隐私合规与数据安全基础材料"
"@
$week09 = Add-Week01CommentSkeleton $week09
Write-Utf8NoBom (Join-Path $baseDir "week09.yaml") $week09

# ---------------- week10 ----------------
$week10 = @"
lesson:
  title: "情感识别与语音理解：从分类到场景"
  chapter_title: "语音理解扩展：情感/意图/场景化应用"
  week_no: 10
  hours: 2
  student_analysis: >
    学生会做分类但不清楚情感标签的主观性与数据偏差风险。
  content_analysis:
    basic: "情感识别任务；标签与数据偏差；简单特征与模型思路；场景落地。"
    key_points: "标签定义与一致性；评估与泛化；合规风险。"
    difficult_points: "处理主观标签与跨域泛化。"
  objectives:
    value: "培养对算法偏差与伦理风险的敏感度。"
    knowledge: "理解情感识别任务与数据标签问题。"
    ability: "能设计一个小型实验并说明偏差来源。"
    quality: "形成负责任AI思维。"
  process:
    - step: 1
      teach_content: "案例导入：情感识别能做什么"
      teacher_action: "展示场景与误判风险"
      student_action: "讨论：误判后果"
      method: "案例分析"
      time: "15分钟"
    - step: 2
      teach_content: "标签与数据偏差"
      teacher_action: "讲解主观标签一致性问题"
      student_action: "提出降低偏差的方法"
      method: "讨论法"
      time: "30分钟"
    - step: 3
      teach_content: "评估与泛化"
      teacher_action: "讲解跨域、交叉验证等概念"
      student_action: "完成一个评估设计题"
      method: "练习法"
      time: "25分钟"
    - step: 4
      teach_content: "总结：负责任的语音AI"
      teacher_action: "给出实践清单"
      student_action: "写出1条合规注意事项"
      method: "讲授法"
      time: "20分钟"
  homework: "选一个情感识别场景，写出数据来源、标签定义、风险点与改进建议。"
  reflection: "伦理内容要结合真实案例，否则学生不敏感。"
  references:
    - "情感识别入门资料"
    - "数据偏差与评估方法说明"
    - "负责任AI相关材料"
"@
$week10 = Add-Week01CommentSkeleton $week10
Write-Utf8NoBom (Join-Path $baseDir "week10.yaml") $week10

# ---------------- week11 ----------------
$week11 = @"
lesson:
  title: "部署入门：实时性、延迟与端侧推理"
  chapter_title: "工程化：部署形态与性能指标"
  week_no: 11
  hours: 2
  student_analysis: >
    学生容易只关注模型精度，忽略延迟、算力、内存等工程约束。
  content_analysis:
    basic: "部署形态（云/端/边）；延迟与吞吐；实时音频流处理基本概念。"
    key_points: "指标：RTF、延迟、内存；工程权衡。"
    difficult_points: "将业务需求转成技术指标。"
  objectives:
    value: "建立‘可用比更准更重要’的工程意识。"
    knowledge: "理解常见部署形态与性能指标。"
    ability: "能为一个应用设定性能目标并给出方案。"
    quality: "培养面向约束的设计能力。"
  process:
    - step: 1
      teach_content: "部署案例导入"
      teacher_action: "展示云端/端侧差异"
      student_action: "讨论：为什么端侧重要"
      method: "讨论法"
      time: "15分钟"
    - step: 2
      teach_content: "性能指标：延迟/吞吐/RTF"
      teacher_action: "解释指标含义与测量方式"
      student_action: "完成指标理解题"
      method: "讲授法"
      time: "30分钟"
    - step: 3
      teach_content: "流式处理与缓存"
      teacher_action: "讲解流式ASR基本结构"
      student_action: "画出流式处理流程"
      method: "启发式"
      time: "25分钟"
    - step: 4
      teach_content: "小练习：给一个App定部署方案"
      teacher_action: "点评方案合理性"
      student_action: "提交方案与指标"
      method: "任务驱动"
      time: "20分钟"
  homework: "选择一个语音应用（字幕/助手/客服），写出部署形态与性能指标目标。"
  reflection: "工程指标最好配一个统一‘需求→指标→方案’表格。"
  references:
    - "端侧推理与部署入门资料"
    - "实时语音处理基础文章"
    - "开源推理框架文档（可选）"
"@
$week11 = Add-Week01CommentSkeleton $week11
Write-Utf8NoBom (Join-Path $baseDir "week11.yaml") $week11

# ---------------- week12 ----------------
$week12 = @"
lesson:
  title: "数据集构建：采集、标注与划分"
  chapter_title: "数据工程：语音数据采集与标注"
  week_no: 12
  hours: 2
  student_analysis: >
    学生对采集和标注缺少经验，容易忽略一致性规范与隐私授权。
  content_analysis:
    basic: "采集流程；标注规范；train/val/test划分；隐私与授权。"
    key_points: "一致性与质量控制；可复现的数据版本管理。"
    difficult_points: "标注规范落地与质检机制。"
  objectives:
    value: "树立合规采集与数据安全意识。"
    knowledge: "掌握数据采集/标注/划分基本方法。"
    ability: "能写出一份小型数据集规范（字段/格式/质检）。"
    quality: "培养规范文档与协作能力。"
  process:
    - step: 1
      teach_content: "引入：数据集决定上限"
      teacher_action: "展示标注不一致带来的问题"
      student_action: "说出‘一致性’为何重要"
      method: "案例分析"
      time: "15分钟"
    - step: 2
      teach_content: "采集与授权"
      teacher_action: "讲解隐私与授权要点"
      student_action: "列出采集注意事项"
      method: "讲授法"
      time: "25分钟"
    - step: 3
      teach_content: "标注规范与质检"
      teacher_action: "给出标注模板与质检流程"
      student_action: "按模板写一条标注规范"
      method: "练习法"
      time: "30分钟"
    - step: 4
      teach_content: "划分与版本管理"
      teacher_action: "讲解划分原则与版本记录"
      student_action: "提交数据规范草案"
      method: "任务驱动"
      time: "20分钟"
  homework: "完成一个‘小数据集规范’（采集、标注、质检、划分、授权说明）。"
  reflection: "合规内容一定要写进模板，避免后续遗漏。"
  references:
    - "数据采集与标注规范示例"
    - "数据版本管理/实验记录参考"
    - "隐私与授权基础材料"
"@
$week12 = Add-Week01CommentSkeleton $week12
Write-Utf8NoBom (Join-Path $baseDir "week12.yaml") $week12

# ---------------- week13 ----------------
$week13 = @"
lesson:
  title: "最小Demo：语音识别/合成的快速上手"
  chapter_title: "工程实践：搭建最小语音应用Demo"
  week_no: 13
  hours: 2
  student_analysis: >
    学生需要一次完整跑通的成功体验，把之前的概念落到可运行系统上。
  content_analysis:
    basic: "选择工具/模型；输入输出；参数设置；简单评估与展示。"
    key_points: "跑通闭环；能解释关键参数；能复现。"
    difficult_points: "环境与依赖问题；把结果做成可展示产物。"
  objectives:
    value: "增强自信与动手能力，形成工程闭环意识。"
    knowledge: "理解Demo所用模型/接口的关键参数。"
    ability: "独立搭建一个最小Demo并展示。"
    quality: "培养排障与文档记录习惯。"
  process:
    - step: 1
      teach_content: "Demo目标与评价标准"
      teacher_action: "给出评分点与示例"
      student_action: "明确自己要做哪个Demo"
      method: "讲授法"
      time: "10分钟"
    - step: 2
      teach_content: "快速搭建（示范）"
      teacher_action: "现场演示搭建步骤"
      student_action: "跟做并记录"
      method: "演示法、实操"
      time: "40分钟"
    - step: 3
      teach_content: "结果展示与简单评估"
      teacher_action: "讲解展示方式与评估"
      student_action: "完成一次展示"
      method: "任务驱动"
      time: "25分钟"
    - step: 4
      teach_content: "总结与问题收集"
      teacher_action: "归纳常见坑并给解决思路"
      student_action: "提交问题清单"
      method: "讨论法"
      time: "15分钟"
  homework: "完善Demo：加入一个‘对比实验’（参数/预处理/模型）并写结论。"
  reflection: "演示要准备离线方案，避免网络/环境翻车。"
  references:
    - "所用模型/工具官方文档"
    - "示例代码仓库/教程"
    - "实验记录模板"
"@
$week13 = Add-Week01CommentSkeleton $week13
Write-Utf8NoBom (Join-Path $baseDir "week13.yaml") $week13

# ---------------- week14 ----------------
$week14 = @"
lesson:
  title: "课程项目启动：需求→流水线→里程碑"
  chapter_title: "项目化：需求拆解与计划制定"
  week_no: 14
  hours: 2
  student_analysis: >
    学生容易把项目做成“堆功能”，缺少里程碑与验收标准。
  content_analysis:
    basic: "项目选题；需求描述；输入/输出定义；里程碑与验收；风险清单。"
    key_points: "把需求拆成模块与任务；明确验收标准。"
    difficult_points: "范围控制与风险管理。"
  objectives:
    value: "建立职业化交付意识。"
    knowledge: "掌握项目计划与验收的基本方法。"
    ability: "能输出项目计划（模块、时间、验收、风险）。"
    quality: "培养团队协作与沟通表达能力。"
  process:
    - step: 1
      teach_content: "项目要求与样例"
      teacher_action: "讲解评分标准与优秀示例"
      student_action: "明确组内分工"
      method: "讲授法"
      time: "15分钟"
    - step: 2
      teach_content: "需求→流水线拆解"
      teacher_action: "指导拆解方法"
      student_action: "完成本组拆解草图"
      method: "任务驱动"
      time: "35分钟"
    - step: 3
      teach_content: "里程碑与验收"
      teacher_action: "给模板：每周产出/验收点"
      student_action: "制定里程碑表"
      method: "讲授法、练习法"
      time: "25分钟"
    - step: 4
      teach_content: "风险清单与备选方案"
      teacher_action: "点评风险是否真实可控"
      student_action: "提交风险与备选"
      method: "讨论法"
      time: "15分钟"
  homework: "提交项目计划书（需求、流水线、里程碑、验收、风险）。"
  reflection: "必须强调‘验收标准’，否则后期评估困难。"
  references:
    - "项目计划与需求文档模板"
    - "语音项目案例参考"
    - "团队协作工具使用说明（可选）"
"@
$week14 = Add-Week01CommentSkeleton $week14
Write-Utf8NoBom (Join-Path $baseDir "week14.yaml") $week14

# ---------------- week15 ----------------
$week15 = @"
lesson:
  title: "项目中期检查：对比实验与问题修复"
  chapter_title: "项目推进：对比实验、优化与排障"
  week_no: 15
  hours: 2
  student_analysis: >
    学生常见问题是缺少对比实验，优化没有依据；排障没有记录导致重复踩坑。
  content_analysis:
    basic: "中期检查；对比实验设计；问题定位；日志与记录；优化路径。"
    key_points: "对比实验必须可复现；问题定位要有证据链。"
    difficult_points: "从现象找到根因并提出可执行修复。"
  objectives:
    value: "建立以证据驱动优化的科研/工程习惯。"
    knowledge: "掌握对比实验与排障记录方法。"
    ability: "能完成一次对比实验并输出结论。"
    quality: "培养规范汇报与迭代意识。"
  process:
    - step: 1
      teach_content: "中期检查标准"
      teacher_action: "说明检查清单"
      student_action: "对照清单自查"
      method: "讲授法"
      time: "10分钟"
    - step: 2
      teach_content: "对比实验设计"
      teacher_action: "给‘只改一个变量’原则"
      student_action: "设计本组对比实验"
      method: "练习法"
      time: "30分钟"
    - step: 3
      teach_content: "排障与记录"
      teacher_action: "示范‘现象→猜测→验证→结论’"
      student_action: "写一条排障记录"
      method: "案例分析"
      time: "30分钟"
    - step: 4
      teach_content: "组间汇报与点评"
      teacher_action: "点评并给下一步建议"
      student_action: "简短汇报"
      method: "讨论法"
      time: "20分钟"
  homework: "提交中期报告：对比实验（含结果）+ 排障记录（至少1条）+ 下一步计划。"
  reflection: "对比实验必须强制，否则项目容易水。"
  references:
    - "实验设计与报告写作模板"
    - "排障记录（issue log）模板"
    - "评估指标与可视化参考"
"@
$week15 = Add-Week01CommentSkeleton $week15
Write-Utf8NoBom (Join-Path $baseDir "week15.yaml") $week15

# ---------------- week16 ----------------
$week16 = @"
lesson:
  title: "项目验收与课程总结：展示、反思与展望"
  chapter_title: "课程收束：项目展示与复盘"
  week_no: 16
  hours: 2
  student_analysis: >
    学生需要明确最终交付物与评价维度，尤其是“可运行、可解释、可复现、可展示”。
  content_analysis:
    basic: "最终展示结构；验收标准；复盘方法；课程总结与后续方向。"
    key_points: "交付物清单；演示脚本；实验记录；复盘与改进。"
    difficult_points: "把过程经验沉淀成可复用资产。"
  objectives:
    value: "形成自我反思与持续学习意识。"
    knowledge: "理解验收与复盘的标准流程。"
    ability: "能完成一次规范展示与复盘报告。"
    quality: "培养表达、总结与职业化交付能力。"
  process:
    - step: 1
      teach_content: "验收标准与展示结构"
      teacher_action: "给出评分表与展示模板"
      student_action: "按模板整理材料"
      method: "讲授法"
      time: "15分钟"
    - step: 2
      teach_content: "项目展示（分组）"
      teacher_action: "组织展示与提问"
      student_action: "展示与回答问题"
      method: "展示法"
      time: "50分钟"
    - step: 3
      teach_content: "复盘：做得好/问题/改进"
      teacher_action: "引导复盘并给改进方向"
      student_action: "提交复盘要点"
      method: "讨论法"
      time: "20分钟"
    - step: 4
      teach_content: "课程总结与展望"
      teacher_action: "总结学习路径，给后续学习建议"
      student_action: "写下个人下一步计划"
      method: "讲授法"
      time: "15分钟"
  homework: "提交最终报告：项目说明+演示说明+实验记录+复盘与展望。"
  reflection: "展示要提前彩排，避免最后一周全是临场排障。"
  references:
    - "项目验收与汇报模板"
    - "实验记录与复盘方法资料"
    - "语音AI进阶学习资源清单"
"@
$week16 = Add-Week01CommentSkeleton $week16
Write-Utf8NoBom (Join-Path $baseDir "week16.yaml") $week16

Write-Host "✅ Generated week02~week16 YAML files at: $baseDir"
Get-ChildItem $baseDir -Filter "week*.yaml" | Sort-Object Name | Select-Object Name, Length