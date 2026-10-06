#!/bin/sh
# Tests for UFL 3.5 generators. Run from the repo root: sh tests/run.sh
# 1. Single-scope output equals the 3.5 text, apart from the version string.
# 2. Published 3.4 (and older) artifacts in pdf/ are untouched since the v3.4 tag, if the tag exists.
# 3. generate.sh and generate.js agree byte for byte, with and without Components.
# 4. Bad Component input is rejected by both generators.
set -u
FAIL=0
fail() { echo "FAIL: $*"; FAIL=1; }
ok() { echo "ok:   $*"; }

SCOPES="unconditional no-competing-service no-third-party-hosting noncommercial seat-limited decentralized paid"
ARGS="-y [YEAR] -c [COPYRIGHT_HOLDER] -p [PROJECT_NAME]"

for sc in $SCOPES; do
  sh generate.sh -y '[YEAR]' -c '[COPYRIGHT HOLDER]' -p '[PROJECT NAME]' -s "$sc" -t '[THRESHOLD]' -k '[NATIVE TOKEN]' 2>/dev/null \
    | sed 's/3\.6/3.5/g' > /tmp/ufl-t.$$
  if [ "$(cat /tmp/ufl-t.$$)" = "$(cat "pdf/UFL-3.5-$sc.txt")" ]; then ok "3.6 = 3.5 text (version aside): $sc"; else fail "3.5 text differs: $sc"; fi
done
rm -f /tmp/ufl-t.$$

if git rev-parse -q --verify refs/tags/v3.4 >/dev/null 2>&1; then
  if git diff --quiet v3.4 -- 'pdf/UFL-1.*' 'pdf/UFL-2.*' 'pdf/UFL-3.0*' 'pdf/UFL-3.1*' 'pdf/UFL-3.2*' 'pdf/UFL-3.3*' 'pdf/UFL-3.4*'; then ok "published pdf/ artifacts through 3.4 unchanged since v3.4"; else fail "published pdf/ artifacts changed"; fi
fi

parity() {
  A=$(sh generate.sh "$@" 2>&1; echo "rc=$?"); B=$(node generate.js "$@" 2>&1; echo "rc=$?")
  if [ "$A" = "$B" ]; then ok "sh == js: $*"; else fail "sh != js: $*"; fi
}
parity -y 2026 -c "Test Holder" -p TestProject -s unconditional
parity -y 2026 -c "Test Holder" -p TestProject -s paid
parity -y 2026 -c "Test Holder" -p TestProject -s seat-limited -t "2 seats" -C "fixer=paid:fix/**"
parity -y 2026 -c "Test Holder" -p TestProject -s unconditional -C "fixer=paid:fix/**,crates/fixer"
parity -y 2026 -c "Test Holder" -p TestProject -s noncommercial -C "fixer=paid:fix/**" -C "docs=unconditional:docs/**, site"
parity -y 2026 -c "Test Holder" -p TestProject -s paid -C "core=unconditional:core/**"
parity -y 2026 -c "Test Holder" -p TestProject -s unconditional -C "x=no-competing-service:a b/&c|d,pkg:e"
parity -y 2026 -c "Test Holder" -p TestProject -s unconditional -C 'q=paid:a"b/$c'
parity -r -s unconditional -C "fixer=paid:fix/**"
parity -r -s noncommercial -C "fixer=paid:fix/**" -C "docs=unconditional:docs"
parity -y 2026 -c "Test Holder" -p TestProject -s decentralized -k TESTTOKEN

for bad in "fixer" "fixer=paid" "Fixer=paid:a" "fixer=bogus:a" "fixer=seat-limited:a" "fixer=decentralized:a" \
           "fixer=unconditional:a" "fixer=paid:" "fixer=paid:a,,b" 'fixer=paid:a\b'; do
  if sh generate.sh -y 1 -c h -p p -s unconditional -C "$bad" >/dev/null 2>&1; then fail "sh accepted: $bad"; else ok "sh rejects: $bad"; fi
  if node generate.js -y 1 -c h -p p -s unconditional -C "$bad" >/dev/null 2>&1; then fail "js accepted: $bad"; else ok "js rejects: $bad"; fi
done
sh generate.sh -y 1 -c h -p p -s decentralized -C "fixer=paid:a" >/dev/null 2>&1 && fail "sh: decentralized with Component accepted" || ok "sh rejects decentralized + Component"
node generate.js -y 1 -c h -p p -s decentralized -C "fixer=paid:a" >/dev/null 2>&1 && fail "js: decentralized with Component accepted" || ok "js rejects decentralized + Component"
sh generate.sh -y 1 -c h -p p -s unconditional -C "a=paid:x" -C "a=noncommercial:y" >/dev/null 2>&1 && fail "sh: duplicate name accepted" || ok "sh rejects duplicate name"
node generate.js -y 1 -c h -p p -s unconditional -C "a=paid:x" -C "a=noncommercial:y" >/dev/null 2>&1 && fail "js: duplicate name accepted" || ok "js rejects duplicate name"

# Contract Releases (since 3.6)
parity -y 2026 -c "Test Holder" -p TestProject -s unconditional -K
parity -y 2026 -c "Test Holder" -p TestProject -s decentralized -k HONE -K
parity -r -s unconditional -K
parity -r -s decentralized -k HONE -K
for badk in "-s noncommercial" "-s paid" "-s seat-limited -t 2" "-s no-competing-service" "-s unconditional -C f=paid:a"; do
  # shellcheck disable=SC2086
  if sh generate.sh -y 1 -c h -p p $badk -K >/dev/null 2>&1; then fail "sh accepted -K with: $badk"; else ok "sh rejects -K with: $badk"; fi
  if node generate.js -y 1 -c h -p p $badk -K >/dev/null 2>&1; then fail "js accepted -K with: $badk"; else ok "js rejects -K with: $badk"; fi
done
K1=$(sh generate.sh -r -s unconditional -K); [ "$K1" = "UFL 3.6, Operational Scope: Unconditional, Contract Release (LicenseRef-UFL-3.6-K)" ] && ok "contract release statement" || fail "contract statement: $K1"
K2=$(sh generate.sh -r -s decentralized -k HONE -K); [ "$K2" = "UFL 3.6, Operational Scope: Decentralized, Contract Release (LicenseRef-UFL-3.6-D-K)" ] && ok "contract decentralized statement" || fail "contract dec statement: $K2"
# a Contract Release license must contain the Contracts paragraphs, and a plain one must not
sh generate.sh -y 1 -c h -p p -s unconditional -K 2>/dev/null | grep -q "^Contracts\. This Release is a Contract Release" && ok "Contracts text present with -K" || fail "Contracts text missing with -K"
sh generate.sh -y 1 -c h -p p -s unconditional 2>/dev/null | grep -q "Contract Release" && fail "Contracts text leaked without -K" || ok "no Contracts text without -K"

# SPDX string and Release statement for the worked example
S=$(sh generate.sh -r -s unconditional -C "snifrig-fix=paid:fix/**")
[ "$S" = "UFL 3.6, Operational Scope: Unconditional; Component snifrig-fix: Paid (LicenseRef-UFL-3.6-U.P-snifrig-fix)" ] && ok "release statement" || fail "release statement: $S"

[ "$FAIL" = 0 ] && echo "ALL PASS" || { echo "FAILURES"; exit 1; }
