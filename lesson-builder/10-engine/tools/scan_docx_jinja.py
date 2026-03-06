import sys, zipfile, re

def scan(docx_path: str):
    print(f"\n=== Scanning: {docx_path} ===")
    z = zipfile.ZipFile(docx_path)

    # 常见可能藏模板语法的位置
    targets = [
        "word/document.xml",
        "word/header1.xml", "word/header2.xml", "word/header3.xml",
        "word/footer1.xml", "word/footer2.xml", "word/footer3.xml",
        "word/footnotes.xml",
        "word/endnotes.xml",
        "word/comments.xml",
    ]

    # 还要把 word/ 目录下所有 xml 都扫一遍（防止文本框等内容在其他 part）
    for name in z.namelist():
        if name.startswith("word/") and name.endswith(".xml") and name not in targets:
            targets.append(name)

    hits = 0
    for name in targets:
        if name not in z.namelist():
            continue
        txt = z.read(name).decode("utf-8", errors="ignore")

        # 把 Word 的标签去掉，方便看到模板语法被拆碎的情况
        flat = re.sub(r"<[^>]+>", "", txt)
        if "endfor" in flat or "{%" in flat or "{{" in flat:
            # 找 endfor 周围的上下文
            for m in re.finditer(r"endfor", flat):
                hits += 1
                s = max(0, m.start() - 80)
                e = min(len(flat), m.end() + 80)
                ctx = flat[s:e].replace("\n", "")
                print(f"[{name}] ...{ctx}...")

    if hits == 0:
        print("✅ No 'endfor' found in XML text.")
    else:
        print(f"\n❗ Found {hits} occurrence(s) of 'endfor'.")

if __name__ == "__main__":
    scan(sys.argv[1])