#!/bin/sh
# generate.sh — fill in a copy of the Usufruct License (UFL) v1.0.
# POSIX shell, no dependencies beyond sed (present on every POSIX system).
#
# Usage:
#   ./generate.sh [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] [-o OUTPUT_PATH]
# Any flag left out is prompted for. With no -o, the filled license is
# written to stdout.
#
# Piped from curl — pass every flag, since stdin is the script itself in
# this mode and interactive prompts have nothing to read:
#   curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.sh \
#     | bash -s -- -y 2026 -c "Jane Doe" -p "MyProject" > LICENSE
#
# Tracks UFL 1.0. See CHANGELOG.md for revisions.

set -eu

YEAR=""
HOLDER=""
PROJECT=""
OUT=""

while getopts "y:c:p:o:h" opt; do
  case "$opt" in
    y) YEAR=$OPTARG ;;
    c) HOLDER=$OPTARG ;;
    p) PROJECT=$OPTARG ;;
    o) OUT=$OPTARG ;;
    h)
      echo "Usage: $0 [-y YEAR] [-c \"COPYRIGHT HOLDER\"] [-p \"PROJECT NAME\"] [-o OUTPUT_PATH]"
      exit 0
      ;;
    *) exit 1 ;;
  esac
done

[ -n "$YEAR" ]    || { printf 'Year: ' >&2; read -r YEAR; }
[ -n "$HOLDER" ]  || { printf 'Copyright holder: ' >&2; read -r HOLDER; }
[ -n "$PROJECT" ] || { printf 'Project name: ' >&2; read -r PROJECT; }

# Escape backslash, ampersand, and the sed delimiter (|) so arbitrary
# names can't break the substitution below.
escape() {
  printf '%s' "$1" | sed -e 's/[\&|]/\\&/g'
}

YEAR_ESC=$(escape "$YEAR")
HOLDER_ESC=$(escape "$HOLDER")
PROJECT_ESC=$(escape "$PROJECT")

FILLED=$(sed \
  -e "s|\[YEAR\]|$YEAR_ESC|g" \
  -e "s|\[COPYRIGHT HOLDER\]|$HOLDER_ESC|g" \
  -e "s|\[PROJECT NAME\]|$PROJECT_ESC|g" <<'UFL_TEMPLATE'
The Usufruct License (UFL) — Version 1.0
Canonical text, whitepaper, and FAQ: https://github.com/estejosh/UFL-Usufruct-License

Copyright (c) [YEAR] [COPYRIGHT HOLDER]

## 1. Grant of Use

Subject to the terms below, the Licensor grants anyone the free,
perpetual, worldwide right to use the Software — in source or compiled
form, for any purpose, including commercial purposes, at any scale —
without payment or a separate license. This includes running the
Software, deploying it, integrating with it through its published
interfaces, and operating a product or service built on top of it.

## 2. Reserved Rights

The following rights are reserved to the Licensor and are NOT granted by
Section 1. They require a separate written license from the Licensor:

  (a) Distributing the Software, or any modified version, fork, or
      substantially similar reimplementation of it, to any third party,
      in source or compiled form.
  (b) Incorporating the Software's source code into another product or
      service that is distributed, sold, or otherwise made available to
      third parties.
  (c) Using the Licensor's name, marks, or claims of compatibility
      ("[PROJECT NAME]-compatible," "built on [PROJECT NAME]," etc.) in
      connection with a distributed derivative.

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
rights, which Section 2 intentionally withholds. The source is public
and free to use at any scale; only redistribution of the Software itself
requires a separate license.

## 7. Notice

The canonical-source line at the top of this license text (or an
equivalent pointer to https://github.com/estejosh/UFL-Usufruct-License)
must be kept intact when this license text is copied into another
project. This is a notice requirement on the license text itself, not a
condition on using the Software — Section 1's grant is unconditional.

---
SPDX identifier: UFL is not on the official SPDX license list. Per SPDX
convention for licenses outside that list, use `LicenseRef-UFL-1.0` —
not a bare `UFL-1.0`, which would misrepresent it as SPDX-registered.
UFL_TEMPLATE
)

if [ -n "$OUT" ]; then
  printf '%s\n' "$FILLED" > "$OUT"
else
  printf '%s\n' "$FILLED"
fi
