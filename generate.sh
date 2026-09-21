#!/bin/sh
# generate.sh — fill in a copy of the Usufruct License (UFL) v2.0.
# POSIX shell, no dependencies beyond sed and awk (present on every POSIX
# system).
#
# Usage:
#   ./generate.sh [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] \
#     [-s SCOPE] [-t THRESHOLD] [-o OUTPUT_PATH]
#
# SCOPE is one of: unconditional (default), no-competing-service,
# no-third-party-hosting, noncommercial, seat-limited. THRESHOLD is only
# used (and required) when SCOPE is seat-limited — free text describing
# the free production tier, e.g. "2 seats, 2 computers, 2 mobile devices".
# Any flag left out is prompted for, except THRESHOLD, which is only
# prompted for when SCOPE is seat-limited. With no -o, the filled license
# is written to stdout.
#
# Piped from curl — pass every flag, since stdin is the script itself in
# this mode and interactive prompts have nothing to read:
#   curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.sh \
#     | bash -s -- -y 2026 -c "Jane Doe" -p "MyProject" -s unconditional > LICENSE
#
# Tracks UFL 2.0. See CHANGELOG.md for revisions.

set -eu

YEAR=""
HOLDER=""
PROJECT=""
SCOPE="unconditional"
THRESHOLD=""
OUT=""

while getopts "y:c:p:s:t:o:h" opt; do
  case "$opt" in
    y) YEAR=$OPTARG ;;
    c) HOLDER=$OPTARG ;;
    p) PROJECT=$OPTARG ;;
    s) SCOPE=$OPTARG ;;
    t) THRESHOLD=$OPTARG ;;
    o) OUT=$OPTARG ;;
    h)
      echo "Usage: $0 [-y YEAR] [-c \"COPYRIGHT HOLDER\"] [-p \"PROJECT NAME\"] [-s SCOPE] [-t THRESHOLD] [-o OUTPUT_PATH]"
      echo "SCOPE: unconditional | no-competing-service | no-third-party-hosting | noncommercial | seat-limited"
      exit 0
      ;;
    *) exit 1 ;;
  esac
done

[ -n "$YEAR" ]    || { printf 'Year: ' >&2; read -r YEAR; }
[ -n "$HOLDER" ]  || { printf 'Copyright holder: ' >&2; read -r HOLDER; }
[ -n "$PROJECT" ] || { printf 'Project name: ' >&2; read -r PROJECT; }

case "$SCOPE" in
  unconditional|no-competing-service|no-third-party-hosting|noncommercial|seat-limited) ;;
  *)
    echo "Unknown SCOPE: $SCOPE" >&2
    echo "Must be one of: unconditional | no-competing-service | no-third-party-hosting | noncommercial | seat-limited" >&2
    exit 1
    ;;
esac

if [ "$SCOPE" = "seat-limited" ]; then
  [ -n "$THRESHOLD" ] || { printf 'Free production threshold (e.g. "2 seats, 2 computers, 2 mobile devices"): ' >&2; read -r THRESHOLD; }
fi

# Escape backslash, ampersand, and the sed delimiter (|) so arbitrary
# names can't break the substitution below.
escape() {
  printf '%s' "$1" | sed -e 's/[\&|]/\\&/g'
}

YEAR_ESC=$(escape "$YEAR")
HOLDER_ESC=$(escape "$HOLDER")
PROJECT_ESC=$(escape "$PROJECT")
THRESHOLD_ESC=$(escape "$THRESHOLD")

case "$SCOPE" in
  unconditional)
    SCOPE_LINE="Unconditional"
    SCOPE_SUFFIX=""
    SCOPE_BODY="Unconditional — Section 1's grant is unconditional: it includes
running the Software, deploying it, integrating with it, and operating
a product or service built on top of it, commercially or otherwise, at
any scale, with no further condition."
    ;;
  no-competing-service)
    SCOPE_LINE="No-Competing-Service"
    SCOPE_SUFFIX="-C"
    SCOPE_BODY="No-Competing-Service — Section 1's grant excludes operating the
Software, or a modified version or fork of it, as a product or service
offered to third parties in competition with a product or service the
Licensor offers using the Software. All other uses described in
Section 1 are unconditional."
    ;;
  no-third-party-hosting)
    SCOPE_LINE="No-Third-Party-Hosting"
    SCOPE_SUFFIX="-H"
    SCOPE_BODY="No-Third-Party-Hosting — Section 1's grant excludes providing the
Software to third parties as a hosted or managed service that gives
those third parties access to substantially all of the Software's
features or functionality. All other uses described in Section 1 are
unconditional."
    ;;
  noncommercial)
    SCOPE_LINE="Noncommercial"
    SCOPE_SUFFIX="-N"
    SCOPE_BODY="Noncommercial — Section 1's grant is limited to non-commercial use.
Commercial use of the Software requires a separate written license
from the Licensor."
    ;;
  seat-limited)
    SCOPE_LINE="Seat-Limited — ${THRESHOLD} free in production"
    SCOPE_SUFFIX="-S"
    SCOPE_BODY="Seat-Limited — Section 1's grant is unconditional for non-production
use. Production use is free up to ${THRESHOLD}; production use beyond
that threshold requires a paid, separate written license from the
Licensor."
    ;;
esac

SCOPE_LINE_ESC=$(escape "$SCOPE_LINE")
SCOPE_SUFFIX_ESC=$(escape "$SCOPE_SUFFIX")

FILLED=$(sed \
  -e "s|\[YEAR\]|$YEAR_ESC|g" \
  -e "s|\[COPYRIGHT HOLDER\]|$HOLDER_ESC|g" \
  -e "s|\[PROJECT NAME\]|$PROJECT_ESC|g" \
  -e "s|\[OPERATIONAL SCOPE\]|$SCOPE_LINE_ESC|g" \
  -e "s|LicenseRef-UFL-2.0\`|LicenseRef-UFL-2.0${SCOPE_SUFFIX_ESC}\`|g" \
  -e "s|\`UFL-2.0\`|\`UFL-2.0${SCOPE_SUFFIX_ESC}\`|g" <<'UFL_TEMPLATE'
The Usufruct License (UFL) — Version 2.0
Canonical text, whitepaper, and FAQ: https://github.com/estejosh/UFL-Usufruct-License

Copyright (c) [YEAR] [COPYRIGHT HOLDER]

Operational Scope: [OPERATIONAL SCOPE]

## 1. Grant of Use

Subject to the terms below and the Operational Scope declared above,
the Licensor grants anyone the free, perpetual, worldwide right to use
the Software — in source or compiled form, at any scale — without
payment or a separate license beyond what Section 1A requires. This
includes running the Software, deploying it, integrating with it
through its published interfaces, and operating a product or service
built on top of it, as scoped by Section 1A.

## 1A. Operational Scope

The Operational Scope declared above states the only limit, if any, on
Section 1's grant. Exactly one scope applies to this Software:

[OPERATIONAL SCOPE BODY]

## 2. Reserved Rights

The following rights are reserved to the Licensor and are NOT granted by
Section 1. They require a separate written license from the Licensor,
except as Section 2A permits:

  (a) Distributing the Software, or any modified version, fork, or
      substantially similar reimplementation of it, to any third party,
      in source or compiled form.
  (b) Incorporating the Software's source code into another product or
      service that is distributed, sold, or otherwise made available to
      third parties.
  (c) Using the Licensor's name, marks, or claims of compatibility
      ("[PROJECT NAME]-compatible," "built on [PROJECT NAME]," etc.) in
      connection with a distributed derivative.

## 2A. Forks of Decentralized or Network Software

If the Software is designed to run as a node, client, or peer in a
decentralized network, blockchain, or similar peer-to-peer protocol,
Section 2(a) does not require a separate license for distributing a
modified version, fork, or independent reimplementation of it —
including to operate a competing network — provided the distributed
work:

  (i) prominently and accurately credits [PROJECT NAME] as the origin
      of the Software or protocol, in its README, whitepaper, or
      equivalent primary documentation; and
  (ii) keeps the canonical-source notice required by Section 7 intact.

Distributing a fork that removes, obscures, or falsifies this
attribution is not permitted under this exception and still requires a
separate license under Section 2(a). This section does not affect
Sections 2(b) or 2(c): incorporating the Software into another
distributed product, and using the Licensor's name or marks to claim
compatibility, still require a separate license regardless of
attribution.

## 3. Why "Usufruct"

In civil law, a usufruct is the right to use property belonging to
another and enjoy its benefits, without the right to alter its substance
or transfer ownership to someone else. This license grants exactly that:
full use, no transfer.

## 4. Contributions

Contributions submitted to a Software repository under this license are
accepted under these same terms and are granted back to the Licensor to
the extent necessary to keep this license enforceable across the
combined work.

## 5. No Warranty

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT.
IN NO EVENT SHALL THE LICENSOR BE LIABLE FOR ANY CLAIM, DAMAGES, OR
OTHER LIABILITY ARISING FROM THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.

## 6. Note on Classification

This is a source-available license, not an OSI-approved open source
license. The Open Source Definition requires unrestricted redistribution
rights, which Section 2 intentionally withholds regardless of
Operational Scope. Some Operational Scopes under Section 1A also
withhold uses the Open Source Definition requires to be unrestricted.
The source is public; which uses are free depends on the Operational
Scope declared above.

## 7. Notice

The canonical-source line at the top of this license text (or an
equivalent pointer to https://github.com/estejosh/UFL-Usufruct-License)
must be kept intact when this license text is copied into another
project. This is a notice requirement on the license text itself, not
an additional condition on using the Software beyond Section 1A.

---
SPDX identifier: UFL is not on the official SPDX license list. Per SPDX
convention for licenses outside that list, use `LicenseRef-UFL-2.0` —
not a bare `UFL-2.0`, which would misrepresent it as SPDX-registered.
UFL_TEMPLATE
)

FILLED=$(printf '%s\n' "$FILLED" | awk -v body="$SCOPE_BODY" '
  $0 == "[OPERATIONAL SCOPE BODY]" { print body; next }
  { print }
')

if [ -n "$OUT" ]; then
  printf '%s\n' "$FILLED" > "$OUT"
else
  printf '%s\n' "$FILLED"
fi
