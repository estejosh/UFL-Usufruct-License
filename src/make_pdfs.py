"""Render one locked, read-only PDF per Operational Scope from the generator's own output.
Usage: python3 src/make_pdfs.py  ->  pdf/UFL-<ver>-<scope>.pdf/.txt + SHA256SUMS (repo root)"""
import hashlib, html, re, secrets, subprocess, json
from pathlib import Path
from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, KeepTogether, HRFlowable
from reportlab.lib.colors import HexColor
from pypdf import PdfReader, PdfWriter
from pypdf.constants import UserAccessPermissions as P

R = Path(__file__).resolve().parent.parent; OUT = R / "pdf"; OUT.mkdir(exist_ok=True)
VER = json.loads((R / "ufl.json").read_text())["version"]
SCOPES = json.loads((R / "ufl.json").read_text())["operationalScopes"]
NAMES = {"unconditional": "Unconditional", "seat-limited": "Seat-Limited",
         "no-third-party-hosting": "No-Third-Party-Hosting",
         "no-competing-service": "No-Competing-Service", "noncommercial": "Noncommercial", "decentralized": "Decentralized", "paid": "Paid"}

F = "/usr/share/fonts/truetype/dejavu/"
pdfmetrics.registerFont(TTFont("Serif", F + "DejaVuSerif.ttf"))
pdfmetrics.registerFont(TTFont("Serif-B", F + "DejaVuSerif-Bold.ttf"))
pdfmetrics.registerFont(TTFont("Sans-B", F + "DejaVuSans-Bold.ttf"))
pdfmetrics.registerFont(TTFont("Mono", F + "DejaVuSansMono.ttf"))
INK, MAROON, MUTED = HexColor("#1e1109"), HexColor("#7d2232"), HexColor("#6b5a48")

body = ParagraphStyle("b", fontName="Serif", fontSize=10, leading=14.2, textColor=INK, spaceAfter=7)
item = ParagraphStyle("i", parent=body, leftIndent=26, firstLineIndent=-18, spaceAfter=3)
head = ParagraphStyle("h", fontName="Sans-B", fontSize=10.5, leading=14, textColor=MAROON, spaceBefore=9, spaceAfter=5)
title = ParagraphStyle("t", fontName="Serif-B", fontSize=20, leading=24, textColor=INK, spaceAfter=4)
meta = ParagraphStyle("m", fontName="Mono", fontSize=8.6, leading=12, textColor=MUTED)
scope_st = ParagraphStyle("s", fontName="Sans-B", fontSize=11, leading=15, textColor=MAROON, spaceBefore=6, spaceAfter=2)

def esc(s):
    s = html.escape(s, quote=False)
    return re.sub(r"`([^`]+)`", r'<font name="Mono" size="9">\1</font>', s)

def story_for(text):
    blocks = text.strip("\n").split("\n\n")
    st, i = [], 0
    # header block: version line, canonical line, copyright, scope line -> rendered as title page block
    for b in blocks:
        b = b.strip("\n")
        if b.startswith("The Usufruct License") or b.startswith("Copyright") or b.startswith("Operational Scope:"):
            continue
        if b.startswith("## "):
            st.append(Paragraph(esc(b[3:]), head)); continue
        if b.startswith("---"):
            st.append(Spacer(1, 6)); st.append(HRFlowable(width="100%", thickness=0.5, color=MUTED))
            st.append(Paragraph(esc(" ".join(l.strip() for l in b.splitlines()[1:])), meta)); continue
        lines = b.split("\n")
        if re.match(r"^  \([a-z]+\) ", lines[0]):
            items, cur = [], []
            for l in lines:
                if re.match(r"^  \([a-z]+\) ", l):
                    if cur: items.append(" ".join(cur))
                    cur = [l.strip()]
                else:
                    cur.append(l.strip())
            items.append(" ".join(cur))
            for it in items:
                m = re.match(r"^(\([a-z]+\)) (.*)$", it)
                st.append(Paragraph(f"{m.group(1)}&nbsp;&nbsp;{esc(m.group(2))}", item))
            st.append(Spacer(1, 4)); continue
        st.append(Paragraph(esc(" ".join(l.strip() for l in lines)), body))
    return st

sums = []
for key, name in NAMES.items():
    txt = subprocess.check_output(["sh", str(R / "generate.sh"), "-y", "[YEAR]", "-c", "[COPYRIGHT HOLDER]",
                                   "-p", "[PROJECT NAME]", "-s", key, "-t", "[THRESHOLD]", "-k", "[NATIVE TOKEN]"], text=True)
    digest = hashlib.sha256(txt.encode()).hexdigest()
    spdx = f"LicenseRef-UFL-{VER}{SCOPES[key]['spdxSuffix']}"
    scope_line = re.search(r"^Operational Scope: (.*)$", txt, re.M).group(1)
    (OUT / f"UFL-{VER}-{key}.txt").write_text(txt)

    buf = BytesIO()
    def footer(c, d):
        c.saveState(); c.setFont("Mono", 7.4); c.setFillColor(MUTED)
        c.drawString(inch, 0.6 * inch, f"UFL {VER} · {name} · {spdx}")
        c.drawRightString(letter[0] - inch, 0.6 * inch, "github.com/estejosh/UFL-Usufruct-License")
        c.drawString(inch, 0.45 * inch, f"SHA-256 of license text: {digest}")
        c.drawRightString(letter[0] - inch, 0.45 * inch, f"page {d.page}")
        c.restoreState()
    doc = SimpleDocTemplate(buf, pagesize=letter, leftMargin=inch, rightMargin=inch, topMargin=0.9 * inch,
                            bottomMargin=0.95 * inch, title=f"The Usufruct License {VER} — {name}",
                            author="estejosh/UFL-Usufruct-License", subject=f"{spdx} · Operational Scope: {name}",
                            creator="UFL make_pdfs.py", keywords=f"UFL, {spdx}, {SCOPES[key]['tag']}")
    st = [Paragraph(f"The Usufruct License (UFL)", title),
          Paragraph(f"Version {VER} · Operational Scope: {esc(scope_line)}", scope_st),
          Paragraph(f"{spdx} · repo tag {SCOPES[key]['tag']} · canonical text, whitepaper, and FAQ: "
                    f"https://github.com/estejosh/UFL-Usufruct-License", meta),
          Spacer(1, 4),
          Paragraph("Copyright (c) [YEAR] [COPYRIGHT HOLDER]", meta),
          Paragraph("Reference copy. This PDF is read-only. A Licensor adopts this text by filling in only the year, "
                    "copyright holder, and project name" + (", and the free threshold," if key == "seat-limited" else ", and the native token (or none)," if key == "decentralized" else ",")
                    + " in its own LICENSE file (Section 2C). The SHA-256 below identifies this exact text.", meta),
          Spacer(1, 6), HRFlowable(width="100%", thickness=0.8, color=MAROON), Spacer(1, 4)]
    st += story_for(txt)
    doc.build(st, onFirstPage=footer, onLaterPages=footer)

    w = PdfWriter(clone_from=PdfReader(BytesIO(buf.getvalue())))
    w.add_metadata({"/UFL-Version": VER, "/UFL-Scope": name, "/UFL-TextSHA256": digest})
    allowed = P.PRINT | P.PRINT_TO_REPRESENTATION | P.EXTRACT | P.EXTRACT_TEXT_AND_GRAPHICS
    w.encrypt(user_password="", owner_password=secrets.token_urlsafe(32), permissions_flag=allowed, algorithm="AES-256")
    pdf_path = OUT / f"UFL-{VER}-{key}.pdf"
    with open(pdf_path, "wb") as f: w.write(f)
    sums.append((hashlib.sha256(pdf_path.read_bytes()).hexdigest(), pdf_path.name))
    sums.append((digest, f"UFL-{VER}-{key}.txt"))
    print(name, "->", pdf_path.name, digest[:16])

# one checksum file at the repo root for every release artifact (sha256sum -c SHA256SUMS)
files = [R / "LICENSE.txt"] + sorted(OUT.glob("*.pdf")) + sorted(OUT.glob("*.txt")) + sorted((R / "assets").glob("*.mp4"))
(R / "SHA256SUMS").write_text("".join(f"{hashlib.sha256(f.read_bytes()).hexdigest()}  {f.relative_to(R).as_posix()}\n" for f in files))
