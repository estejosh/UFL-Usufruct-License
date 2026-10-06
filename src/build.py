"""Single source of truth for UFL 3.6: src/template.txt + src/scopes.json ->
LICENSE.txt, and the template/scope blocks inside generate.sh and generate.js."""
import json, re, textwrap
from pathlib import Path
R = Path(__file__).resolve().parent.parent; S = R / "src"
VER_OLD, VER = "3.5", "3.6"

def wrap_par(p, w=72):
    lines = p.split("\n")
    if len(lines) > 1 and all(re.match(r"^  \([a-z]+\) ", l) for l in lines):
        return "\n".join(wrap_par(l, w) for l in lines)
    m = re.match(r"^  (\([a-z]+\)) (.*)$", p, re.S)
    if m:
        return textwrap.fill(m.group(2), w, initial_indent=f"  {m.group(1)} ",
                             subsequent_indent="      ", break_on_hyphens=False)
    if p.startswith("## ") or p.startswith("["):
        return p
    return textwrap.fill(p, w, break_on_hyphens=False, break_long_words=False)

def render_template():
    src = (S / "template.txt").read_text()
    out, raw = [], False
    blocks = re.split(r"(@@RAW\n.*?@@END\n)", src, flags=re.S)
    for b in blocks:
        if b.startswith("@@RAW"):
            out.append(b[len("@@RAW\n"):-len("@@END\n")].rstrip("\n"))
        else:
            for p in [x.strip("\n") for x in b.split("\n\n") if x.strip()]:
                out.append(wrap_par(p))
    return "\n\n".join(out) + "\n"

TPL = render_template()
SC = json.loads((S / "scopes.json").read_text())
CI = json.loads((S / "components.json").read_text())
KT = json.loads((S / "contract.json").read_text())
def _lines(ps): return "\n\n".join(textwrap.fill(p, 72, break_on_hyphens=False) for p in ps).split("\n")
CONTRACT_LINES, CONTRACT_DEC_LINES = _lines(KT["intro"]), _lines(KT["decentralized"])
INTRO_LINES = "\n\n".join(textwrap.fill(p, 72, break_on_hyphens=False) for p in CI["intro"]).split("\n")
def body_lines(key):
    return textwrap.fill(SC[key]["body"], 72, break_on_hyphens=False).split("\n")

# canonical LICENSE.txt = Unconditional rendering with identity blanks left in
lic = TPL.replace("[OPERATIONAL SCOPE BODY]", "\n".join(body_lines("unconditional"))) \
         .replace("[OPERATIONAL SCOPE]", SC["unconditional"]["line"])
(R / "LICENSE.txt").write_text(lic)

# ---- generate.sh
sh = (R / "generate.sh").read_text()
sh = re.sub(r"(<<'UFL_TEMPLATE'\n).*?(\nUFL_TEMPLATE\n)", lambda m: m.group(1) + TPL.rstrip("\n") + m.group(2), sh, flags=re.S)
for key in SC:
    lines = "\n".join(body_lines(key)).replace("@THRESHOLD@", "${THRESHOLD}").replace("@TOKEN@", "${TOKEN}")
    sh = re.sub(rf'(  {key}\)\n(?:    SCOPE_LINE=[^\n]*\n)(?:    SCOPE_SUFFIX=[^\n]*\n)    SCOPE_BODY=").*?(")(\n    ;;)',
                lambda m: m.group(1) + lines + m.group(2) + m.group(3), sh, flags=re.S)
sh = re.sub(r"(cat <<'UFL_COMPONENTS'\n).*?(\nUFL_COMPONENTS\n)", lambda m: m.group(1) + "\n".join(INTRO_LINES) + m.group(2), sh, flags=re.S)
sh = re.sub(r"(cat <<'UFL_CONTRACT'\n).*?(\nUFL_CONTRACT\n)", lambda m: m.group(1) + "\n".join(CONTRACT_LINES) + m.group(2), sh, flags=re.S)
sh = re.sub(r"(cat <<'UFL_CONTRACT_DEC'\n).*?(\nUFL_CONTRACT_DEC\n)", lambda m: m.group(1) + "\n".join(CONTRACT_DEC_LINES) + m.group(2), sh, flags=re.S)
sh = sh.replace(f"v{VER_OLD}", f"v{VER}").replace(f"Tracks UFL {VER_OLD}", f"Tracks UFL {VER}") \
       .replace(f"LicenseRef-UFL-{VER_OLD}", f"LicenseRef-UFL-{VER}").replace(f"`UFL-{VER_OLD}", f"`UFL-{VER}") \
       .replace(f"UFL {VER_OLD}, Operational", f"UFL {VER}, Operational")
(R / "generate.sh").write_text(sh)

# ---- generate.js
js = (R / "generate.js").read_text()
tpl_js = "const TEMPLATE = [\n" + ",\n".join("  " + json.dumps(l, ensure_ascii=False) for l in TPL.rstrip("\n").split("\n")) + ",\n  ''\n].join('\\n');"
js = re.sub(r"const TEMPLATE = \[\n.*?\]\.join\('\\n'\);", lambda m: tpl_js, js, flags=re.S)
def jsbody(key):
    return "[\n" + ",\n".join("      " + json.dumps(l, ensure_ascii=False) for l in body_lines(key)) + "\n    ]"
scopes_js = "const SCOPES = {\n" + ",\n".join(
    f"  {json.dumps(k)}: {{\n    line: {json.dumps(SC[k]['line'], ensure_ascii=False)},\n    suffix: {json.dumps(SC[k]['suffix'])},\n    body: {jsbody(k)}\n  }}"
    for k in SC) + "\n};\n\nfunction buildScope(scopeKey, threshold, token) {\n  const s = SCOPES[scopeKey];\n  const t = (x) => x.split('@THRESHOLD@').join(threshold).split('@TOKEN@').join(token);\n  return { line: t(s.line), suffix: s.suffix, body: s.body.map(t) };\n}"
js = re.sub(r"const SCOPES = \{.*?\n\};\n\nfunction buildScope\(scopeKey, threshold, token\) \{.*?\n\}", lambda m: scopes_js, js, flags=re.S)
js = re.sub(r"const COMPONENT_INTRO = \[\n.*?\n\];", lambda m: "const COMPONENT_INTRO = [\n" + ",\n".join("  " + json.dumps(l, ensure_ascii=False) for l in INTRO_LINES) + "\n];", js, flags=re.S)
def _jsarr(name, lines): return f"const {name} = [\n" + ",\n".join("  " + json.dumps(l, ensure_ascii=False) for l in lines) + "\n];"
js = re.sub(r"const CONTRACT_INTRO = \[\n.*?\n\];", lambda m: _jsarr("CONTRACT_INTRO", CONTRACT_LINES), js, flags=re.S)
js = re.sub(r"const CONTRACT_DEC = \[\n.*?\n\];", lambda m: _jsarr("CONTRACT_DEC", CONTRACT_DEC_LINES), js, flags=re.S)
js = js.replace(f"v{VER_OLD}", f"v{VER}").replace(f"Tracks UFL {VER_OLD}", f"Tracks UFL {VER}") \
       .replace(f"LicenseRef-UFL-{VER_OLD}", f"LicenseRef-UFL-{VER}").replace(f"`UFL-{VER_OLD}", f"`UFL-{VER}") \
       .replace(f"UFL {VER_OLD}, Operational", f"UFL {VER}, Operational")
(R / "generate.js").write_text(js)
print("built", len(lic.splitlines()), "lines")
