#!/bin/sh
# generate.sh — fill in a copy of the Usufruct License (UFL) v3.6.
# POSIX shell, no dependencies beyond sed and awk (present on every POSIX
# system).
#
# Usage:
#   ./generate.sh [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] \
#     [-s SCOPE] [-t THRESHOLD] [-k TOKEN] [-C COMPONENT]... [-K] [-o OUTPUT_PATH]
#   ./generate.sh -r [-s SCOPE] [-t THRESHOLD]
#
# SCOPE is one of: unconditional (default), no-competing-service,
# no-third-party-hosting, noncommercial, seat-limited, decentralized, paid.
# SCOPE governs all of the Software that no Component covers. -C declares a
# Component, a part of the Software with its own scope (since 3.5), as
# NAME=SCOPE:PATH[,PATH...], for example
#   -C "snifrig-fix=paid:fix/**,crates/snifrig-fix"
# and may be repeated. NAME is lowercase letters, digits, and hyphens. A
# Component's SCOPE is one of unconditional, no-competing-service,
# no-third-party-hosting, noncommercial, paid; SCOPE for the rest of the
# Software may be any scope except decentralized, which allows no Components.
# -K declares a Contract Release (since 3.6): the Software is, or includes,
# smart contracts. It needs SCOPE unconditional or decentralized, allows no
# Components, and adds the Contracts paragraphs to Section 1A and -K to the
# SPDX suffix. With -r it adds ", Contract Release" to the Release statement.
# A PATH is a path or glob relative to the root of the Release, or a package
# name; it may not contain a backslash or a comma. A file that more than one
# Component covers belongs to the Component listed first. TOKEN is
# used only when SCOPE is decentralized: the native token of the Software
# (default "none"), in which the $1 remedy may be paid. THRESHOLD is only
# used (and required) when SCOPE is seat-limited — free text describing
# the free production tier, e.g. "2 seats, 2 computers, 2 mobile devices".
# Any flag left out is prompted for, except THRESHOLD, which is only
# prompted for when SCOPE is seat-limited. With no -o, the filled license
# is written to stdout.
#
# -r prints the Release statement (Section 1C) for SCOPE instead of a
# license: the line to publish with each Release, naming its Ruling
# License. It asks for no year, holder, or project.
#
# This script fills in the placeholders and picks one Operational Scope —
# it does not otherwise alter the license text. See Section 2C.
#
# Piped from curl — pass every flag, since stdin is the script itself in
# this mode and interactive prompts have nothing to read:
#   curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.sh \
#     | bash -s -- -y 2026 -c "Jane Doe" -p "MyProject" -s unconditional > LICENSE
#
# Tracks UFL 3.6. See CHANGELOG.md for revisions.

set -eu

YEAR=""
HOLDER=""
PROJECT=""
SCOPE="unconditional"
THRESHOLD=""
TOKEN=""
COMPS=""
CONTRACT=0
OUT=""
RELEASE=0

while getopts "y:c:p:s:t:k:C:o:rKh" opt; do
  case "$opt" in
    y) YEAR=$OPTARG ;;
    c) HOLDER=$OPTARG ;;
    p) PROJECT=$OPTARG ;;
    s) SCOPE=$OPTARG ;;
    t) THRESHOLD=$OPTARG ;;
    k) TOKEN=$OPTARG ;;
    C) COMPS="${COMPS:+$COMPS
}$OPTARG" ;;
    o) OUT=$OPTARG ;;
    r) RELEASE=1 ;;
    K) CONTRACT=1 ;;
    h)
      echo "Usage: $0 [-y YEAR] [-c \"COPYRIGHT HOLDER\"] [-p \"PROJECT NAME\"] [-s SCOPE] [-t THRESHOLD] [-k TOKEN] [-C COMPONENT]... [-K] [-o OUTPUT_PATH] | -r [-s SCOPE] [-t THRESHOLD] [-k TOKEN] [-C COMPONENT]... [-K]"
      echo "SCOPE: unconditional | no-competing-service | no-third-party-hosting | noncommercial | seat-limited | decentralized | paid"
      echo "COMPONENT: NAME=SCOPE:PATH[,PATH...]  (SCOPE: unconditional | no-competing-service | no-third-party-hosting | noncommercial | paid)"
      exit 0
      ;;
    *) exit 1 ;;
  esac
done

[ "$RELEASE" = 1 ] || [ -n "$YEAR" ] || { printf 'Year: ' >&2; read -r YEAR; }
[ "$RELEASE" = 1 ] || [ -n "$HOLDER" ]  || { printf 'Copyright holder: ' >&2; read -r HOLDER; }
[ "$RELEASE" = 1 ] || [ -n "$PROJECT" ] || { printf 'Project name: ' >&2; read -r PROJECT; }

case "$SCOPE" in
  unconditional|no-competing-service|no-third-party-hosting|noncommercial|seat-limited|decentralized|paid) ;;
  *)
    echo "Unknown SCOPE: $SCOPE" >&2
    echo "Must be one of: unconditional | no-competing-service | no-third-party-hosting | noncommercial | seat-limited | decentralized | paid" >&2
    exit 1
    ;;
esac

if [ "$SCOPE" = "seat-limited" ]; then
  [ -n "$THRESHOLD" ] || { printf 'Free production threshold (e.g. "2 seats, 2 computers, 2 mobile devices"): ' >&2; read -r THRESHOLD; }
fi

# Decentralized only: the project's native token, if it has one.
[ -n "$TOKEN" ] || TOKEN="none"
if [ "$SCOPE" = "decentralized" ] && [ "$RELEASE" != 1 ]; then
  echo "Note: Decentralized takes effect only if your Software presents the Section 9 click-through before first use. Without it, the Software is licensed as Unconditional." >&2
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

set_scope() {
case "$1" in
  unconditional)
    SCOPE_LINE="Unconditional"
    SCOPE_SUFFIX=""
    SCOPE_BODY="Unconditional — Section 1's grant is unconditional: it includes running
the Software, deploying it, integrating with it, and operating a product
or service built on top of it, commercially or otherwise, at any scale,
with no further condition."
    ;;
  no-competing-service)
    SCOPE_LINE="No-Competing-Service"
    SCOPE_SUFFIX="-C"
    SCOPE_BODY="No-Competing-Service — Section 1's free grant excludes operating the
Software, or a modified version or fork of it, as a product or service
offered to third parties in competition with a product or service the
Licensor offers using the Software. That excluded use is Paid Use under
Section 8. All other uses described in Section 1 are unconditional."
    ;;
  no-third-party-hosting)
    SCOPE_LINE="No-Third-Party-Hosting"
    SCOPE_SUFFIX="-H"
    SCOPE_BODY="No-Third-Party-Hosting — Section 1's free grant excludes providing the
Software to third parties as a hosted or managed service that gives
those third parties access to substantially all of the Software's
features or functionality. That excluded use is Paid Use under Section
8. All other uses described in Section 1 are unconditional."
    ;;
  noncommercial)
    SCOPE_LINE="Noncommercial"
    SCOPE_SUFFIX="-N"
    SCOPE_BODY="Noncommercial — Section 1's free grant is limited to non-commercial use.
Commercial use of the Software is Paid Use under Section 8."
    ;;
  decentralized)
    SCOPE_LINE="Decentralized"
    SCOPE_SUFFIX="-D"
    SCOPE_BODY="Decentralized — Section 1's grant is unconditional, as in Unconditional,
and no use is Paid Use, so Sections 8 and 10 through 13 do not operate
and Section 9 does. The Software is released as is to the public. Every
dispute arising from its use is decided exclusively by arbitration under
the Rules of Arbitration of the International Chamber of Commerce,
conducted online before a single arbitrator seated in California, on an
individual basis and not as a class or collective action, and no party
consents to the jurisdiction of any court by using the Software. The
arbitrator applies the UNIDROIT Principles of International Commercial
Contracts and, for any matter they do not answer, California law. Native
token of the Software: ${TOKEN}. Each party's total liability to the
other for all claims arising from the Software or this license is
limited, to the extent the law allows, to one United States dollar in
value. The paying party chooses whether to pay in money or, if a native
token is named in this paragraph, in that token valued at one United
States dollar at its market price when paid, and the party being paid
must accept payment in the token if the paying party chooses it. The
paying party pays in the token by notifying the other party in writing
that payment is available; if that party gives no wallet address within
90 days of the notice, the payment is complete and the obligation is
discharged. The market price of the token is its volume-weighted average
price over the 24 hours before payment on the exchange with the highest
trading volume for it. A token is unlisted if no exchange publishes such
a price for it when payment is made, and one unit of an unlisted token
is treated as worth one United States dollar. If the token cannot be
delivered for any reason other than the payee's failure to give an
address, payment is one United States dollar in money, and the payee
bears the cost of the wire or transfer, which the paying party may
deduct from the payment. This scope's dispute process, limit of
liability, and own-risk terms take effect for a Licensee only when the
Licensee completes the affirmative step in Section 9, which the Software
must present before first use and which shows them. The Software must
not run until the Licensee has completed that step, so a Licensee found
running the Software is treated as having completed it, and running the
Software with that step bypassed, removed, or forged breaches this
license and makes that copy a modified version, so the Licensor owes the
person running it no liability of any kind, including the amount stated
below. A Licensor adopts this scope only by building that step into the
Software as a gate, and Software that does not have it is licensed under
the Unconditional scope instead. A modified version, fork, or
independent reimplementation of the Software is not the Software for the
purposes of this scope. Whoever creates, distributes, or uses one does
so entirely at their own risk, and the Licensor has no liability for it
of any kind, including the amount stated above. In any arbitration or
court proceeding under this license, each party bears its own costs and
attorney fees, except that the arbitrator or court may award reasonable
costs and fees against a party whose claim or defense is frivolous or
brought in bad faith, and that award is outside the limit. Nothing in
this scope limits liability that the law does not allow to be limited,
waives a claim or right that the law gives a party and does not allow to
be waived, or limits a party's right to seek an injunction in court to
stop conduct that Section 2 reserves or that infringes the Licensor's
intellectual property."
    ;;
  seat-limited)
    SCOPE_LINE="Seat-Limited — ${THRESHOLD} free in production"
    SCOPE_SUFFIX="-S"
    SCOPE_BODY="Seat-Limited — Section 1's grant is unconditional for Non-Production
Use. Production Use is free up to ${THRESHOLD}; Production Use beyond
that threshold is Paid Use under Section 8."
    ;;
  paid)
    SCOPE_LINE="Paid"
    SCOPE_SUFFIX="-P"
    SCOPE_BODY="Paid — Section 1's free grant is limited to reading and studying the
Software's source. Every other use of the Software, Non-Production Use
included, by any Licensee, whether an organization or an individual and
whether for business or personal purposes, is Paid Use under Section 8.
The Licensor may publish a Published Price of zero, or one that covers
only a trial period."
    ;;
esac
}
set_scope "$SCOPE"

# ---- Components (since 3.5): parts of the Software with their own scope.
die() { echo "$*" >&2; exit 1; }
scope_letter() {
  case "$1" in
    unconditional) echo U ;; no-competing-service) echo C ;;
    no-third-party-hosting) echo H ;; noncommercial) echo N ;;
    seat-limited) echo S ;; decentralized) echo D ;; paid) echo P ;;
  esac
}
contract_text() {
cat <<'UFL_CONTRACT'
Contracts. This Release is a Contract Release: the Software is, or
includes, smart contracts, which are programs deployed to a blockchain
or similar distributed ledger and executed by it. In the paragraphs
below, "Source" means the human-readable source code of the Software,
"Bytecode" means its compiled form, a "Deployment" means one deployment
of that Bytecode at one address on one chain, and "calling" a Deployment
means sending a transaction or message to it, reading from it, or
invoking it from any wallet, script, application, or other contract,
directly or through any intermediary. The choice to declare a Contract
Release is made once for the Release, as the choice of scope is, and
adds nothing to this license beyond these paragraphs. A Contract
Release's scope may be Unconditional or Decentralized, and it declares
no Components.

Calling a Deployment, integrating with it, and composing with it,
including by other contracts, is free and unconditional for everyone,
under any Operational Scope. It needs no payment, permission, or
acceptance. Nothing in this license limits which contract, wallet, or
person may call a Deployment, or what they do with what it returns.
Calling a Deployment is not distributing it, is not incorporating it
into another product under Section 2(b), and does not make the calling
contract, front end, script, or application a modified version or
derivative of it. Writing code that uses a Deployment's published
interface to call it is likewise free.

Section 2(a) applies to a Contract Release in this way. A copy of
Bytecode is a copy of the Software, whether or not the person who makes
it has the Source. Deploying Bytecode of the Software, or Bytecode
compiled from the Source or from a modified or substantially similar
version of it, to a chain where anyone other than the person who
deployed it can call it is a reserved act under Section 2(a), unless the
paragraph on redeployment below permits it. These are not reserved acts
for anyone: the Licensor's publication of the Source; the publication of
verified Source by a block explorer or verification service; the copying
of Bytecode by nodes and clients as an ordinary part of operating a
chain; reading and studying the Source; and running Bytecode on a local,
private, or public test chain to evaluate, develop, test, or demonstrate
it, so long as that deployment holds nothing of real value and is not
offered to others as a way to use the Software in place of the
Deployment. Importing or inheriting the Source into other Source, or
including it in another contract's Source, copies the Software and is a
reserved act on the same terms as deploying its Bytecode. Using only the
Deployment's published interface to call it is not copying and is free,
as the paragraph on calling says.

Section 2A applies to a redeployment of a Contract Release as if it were
a fork of decentralized software, even though a contract is not a node,
client, or peer. A person may redeploy the Software, or a modified
version of it, on these conditions: (i) the redeployed Source carries at
its top the notice described below, unchanged, and a statement that it
is derived from [PROJECT NAME] that names the origin Deployment by chain
and address, and the same credit appears in the redeployment's
documentation, or, where the Source is not shown, in its published
metadata; (ii) the parts taken from the Software stay under this
license; and (iii) the person redeploys at their own risk, and the
Licensor has no liability of any kind for the redeployment, for anything
it does, or for any loss of assets in it. A redeployment without that
credit, or with the notice removed or falsified, is not permitted by
Section 2A and needs a separate license under Section 2(a). Section 2(c)
is unchanged: a redeployment may not use the Licensor's name or marks to
claim compatibility.

A caller sees no terms before calling, and a Deployment cannot present
the step that Section 9 describes. This license therefore does not treat
calling a Deployment as acceptance of anything, and does not bind a
person who only calls a Deployment to any term that depends on
acceptance. Sections 2 and 2A bind a person who deploys or redeploys,
without acceptance, because they limit what a person may do with someone
else's copyrighted work. A term that needs acceptance, such as a limit
of liability or a dispute process in the Operational Scope, binds a
person who completes the Section 9 step in a front end, app, wallet, or
tool that the Licensor provides for using the Deployment, and only that
person. A person who completes no such step, a plain caller included, is
bound by none of those terms and has the rights the law gives them
against the Licensor. The step is shown and recorded as Section 9
provides, and the record stays on the Licensee's own systems: neither a
Deployment nor the Licensor's tools write a record of acceptance to a
chain. Where a Deployment's governance, whether a vote, a timelock, or
another process the Software's own rules set, points a proxy back at an
implementation that is already deployed, that is not a new Release and
not a move to an earlier version of this license: the earlier
implementation keeps the Ruling License it always had. Whether and when
to do so is for that governance, and is not the Licensor's alone to
decide.

A Release of a Contract Release is one Deployment, identified by its
chain, its address, and the hash of its verified Source, or a set of
Deployments published together from the same Source. Its Ruling License
is the one its notice states. A proxy contract is not a Release of its
own: each implementation contract that a proxy points to is its own
Release, with its own Ruling License, fixed when that implementation is
deployed. Pointing a proxy at a new implementation publishes a later
Release, subject to Section 1C, including its rules that a Licensor
moves only forward and gives notice of a move; the new implementation's
notice, and the places where the Licensor announces upgrades, give that
notice. The Ruling License of the implementation that was replaced, and
the rights it gave, do not change.

The Source of each Contract Release begins with an SPDX line naming this
license's identifier as the generator prints it, followed by a comment
that names this license, its version, and the Operational Scope, gives
the canonical source https://github.com/estejosh/UFL-Usufruct-License,
and states the SHA-256 hash of the license file kept in the Licensor's
repository for that Release. That notice is the statement of the Ruling
License that Section 1C calls for, and counts as including the license
text with the Deployment; the full text is in the Licensor's repository
at the commit the Source was published from. Where Source is flattened
into one file, the file's SPDX line may be an SPDX expression that lists
each license that applies to code in the file, and this license applies
only to the code that is under it. This license governs the Release it
is published with and the code that is under it. Other releases of the
same project, including earlier ones under another license such as MIT,
keep the terms they were published under. A person who forks, redeploys,
verifies, lists, indexes, or builds on the Software is responsible for
their own software and for the licenses it carries, and nothing here
makes the Licensor responsible for what they publish. A block explorer
or verification service that only displays Source is not making a
reserved act.

This notice states what a person who calls a Deployment should know.
Where the Software is decentralized in fact, that is, it has no
administrator key, no upgrade key, and no pause or seizure function held
by the Licensor or anyone else, then once it is deployed it runs as
public, shared software: it is maintained in public, anyone can read it,
and anyone can propose updates to its Source, but there is no company or
person who operates it, who can reverse or correct what it does, or who
can be sued over it. A Deployment can hold or move assets, can lose them
through an error in the Software or in anything it calls, and cannot be
changed after it is deployed unless it was built to be upgraded. The
Software, including each Deployment, is provided as is, as Section 5
says, and a person who calls a Deployment does so at their own risk. A
Licensor that keeps such a key or function must say so in the Source
notice and must not describe the Software as decentralized. This
paragraph is a notice. It does not limit any liability that the law does
not allow to be limited, and it does not bind anyone to any term.

A Deployment can hold or move assets, can lose them through an error in
the Software or in anything it calls, and cannot be changed after it is
deployed unless it was built to be upgraded. The Software, including
each Deployment, is provided as is, as Section 5 says, to everyone who
uses it, and a person who calls a Deployment does so at their own risk.
This paragraph is a notice. It does not limit any liability that the law
does not allow to be limited, and it does not bind anyone to any term.
UFL_CONTRACT
}
contract_dec_text() {
cat <<'UFL_CONTRACT_DEC'
The Decentralized scope above applies to a Contract Release as the
paragraph on acceptance says: to a person through the step in a front
end, app, wallet, or tool that the Licensor provides, and to a person
who redeploys under Section 2A, to whom its limit of liability, payment,
and dispute terms also apply. Where the scope speaks of the Software
running, or of its step being bypassed, removed, or forged, it means
that front end, app, wallet, or tool and not a Deployment: a Deployment
is called without any step, and calling one is not a breach. The scope's
rule that Software without the step is licensed under the Unconditional
scope applies to a Contract Release whose Licensor provides no such
tool, and for it the paragraph on acceptance is all that binds anyone to
a term that needs acceptance.
UFL_CONTRACT_DEC
}
comp_intro() {
cat <<'UFL_COMPONENTS'
Components. This Release may declare Components in the header above. A
Component is a part of the Software that the header identifies by file
path, glob, directory, or package name, and for which it states its own
Operational Scope. A path or glob is read relative to the root of the
Release, where * matches within one path segment and ** matches across
segments; a name that is not a path identifies the package of that name
in the Release. The scope stated first governs all of the Software that
no Component covers. Each Component is governed by the scope the header
states for it. The statement above that exactly one scope applies is
read as applying once to the Software outside the Components and once to
each Component. In the scope that governs a Component, "the Software"
means that Component, and in the scope stated first it means the
Software outside the Components. A file or package that more than one
Component covers belongs to the Component the header lists first.

A use of a Component is any use of the Software that runs code of that
Component, whether directly or through a call from other code. Code of a
Component that is present in a copy of the Software but is never run is
not used. A Licensee that uses only the Software outside the Components,
and Components whose scope leaves that use free, owes nothing for any
Component whose scope withholds a use. A Component whose scope withholds
a use does not make any other part of the Software Paid Use and does not
limit the Licensee's rights in any other part of it.

Sections 8 through 13 apply to each Component whose scope withholds a
use as if that Component were the whole Software. Each such Component
has its own Published Price, which is a price for that Component only.
Amounts owed, usage statements under Section 10, output marks under
Section 11, and Retroactive Licenses under Section 12 are figured
Component by Component, and each mark identifies only the Component that
produced the output. Paying for Paid Use of one part of the Software
covers only that part. The step that Section 9 requires is presented,
for each Component whose scope withholds a use, before that Component
first runs. It names this license's version, the Component, and its
scope, and shows where that Component's Published Price is published.
Sections 1C, 2 through 7, 14, and 15 treat the Software and all of its
Components as one.

A Release that declares Components makes the choice described in Section
2C once for the Software outside the Components and once for each
Component. The name of each Component, the paths or packages that
identify it, and its scope are filled in as the copyright year, holder,
and project name are, and no other term of this license changes. The
scope of a Component may be any Operational Scope in this Section 1A
except Seat-Limited and Decentralized. The scope of the Software outside
the Components may be any Operational Scope except Decentralized, which
applies only to a Release without Components. The statement of the
Release's Ruling License under Section 1C names this version, the scope
stated first, and each Component with its scope.
UFL_COMPONENTS
}
DEF_LINE=$SCOPE_LINE
DEF_BODY=$SCOPE_BODY
COMP_HDR=""
COMP_STMT=""
if [ -n "$COMPS" ]; then
  [ "$SCOPE" != "decentralized" ] || die "SCOPE decentralized allows no Components (-C)."
  NL='
'
  SEEN="|"
  COMP_BLOCK=""
  SPDX_COMPS=""
  while IFS= read -r spec; do
    case "$spec" in
      *=*:*) ;;
      *) die "Bad -C value: $spec (expected NAME=SCOPE:PATH[,PATH...])" ;;
    esac
    cname=${spec%%=*}
    crest=${spec#*=}
    cscope=${crest%%:*}
    cpats=${crest#*:}
    printf '%s' "$cname" | grep -Eq '^[a-z0-9][a-z0-9-]*$' || die "Bad Component name: $cname (lowercase letters, digits, hyphens)"
    case "$SEEN" in *"|$cname|"*) die "Duplicate Component name: $cname" ;; esac
    SEEN="$SEEN$cname|"
    case "$cscope" in
      unconditional|no-competing-service|no-third-party-hosting|noncommercial|paid) ;;
      *) die "Bad Component scope: $cscope. Must be one of: unconditional | no-competing-service | no-third-party-hosting | noncommercial | paid" ;;
    esac
    [ "$cscope" != "$SCOPE" ] || die "Component $cname has the same scope as the rest of the Software; omit it."
    case "$cpats" in *\\*) die "Component $cname: a PATH may not contain a backslash." ;; esac
    cnorm=$(printf '%s\n' "$cpats" | awk -F, '{ for (i = 1; i <= NF; i++) { gsub(/^[ \t]+|[ \t]+$/, "", $i); if ($i == "") bad = 1; else { sep = (out == "" ? "" : ", "); out = out sep $i } } if (bad || out == "") exit 1; printf "%s", out }') || die "Component $cname: PATH list is empty or has an empty item."
    set_scope "$cscope"
    COMP_HDR="${COMP_HDR:+$COMP_HDR$NL}Component $cname: $SCOPE_LINE ($cnorm)"
    COMP_STMT="$COMP_STMT; Component $cname: $SCOPE_LINE"
    COMP_BLOCK="${COMP_BLOCK:+$COMP_BLOCK$NL$NL}Component $cname (covers $cnorm):$NL$SCOPE_BODY"
    SPDX_COMPS="$SPDX_COMPS.$(scope_letter "$cscope")-$cname"
  done <<UFL_COMPLIST
$COMPS
UFL_COMPLIST
  SCOPE_LINE=$DEF_LINE
  SCOPE_BODY="$DEF_BODY$NL$NL$(comp_intro)$NL$NL$COMP_BLOCK"
  SCOPE_SUFFIX="-$(scope_letter "$SCOPE")$SPDX_COMPS"
else
  SCOPE_LINE=$DEF_LINE
  SCOPE_BODY=$DEF_BODY
fi

# ---- Contract Release (since 3.6): the Software is, or includes, smart contracts.
CONTRACT_STMT=""
if [ "$CONTRACT" = 1 ]; then
  [ -z "$COMPS" ] || die "Contract mode (-K) allows no Components (-C)."
  case "$SCOPE" in
    unconditional|decentralized) ;;
    *) die "Contract mode (-K) requires SCOPE unconditional or decentralized." ;;
  esac
  NL='
'
  SCOPE_BODY="$DEF_BODY$NL$NL$(contract_text)"
  if [ "$SCOPE" = "decentralized" ]; then
    SCOPE_BODY="$SCOPE_BODY$NL$NL$(contract_dec_text)"
  fi
  SCOPE_SUFFIX="${SCOPE_SUFFIX}-K"
  CONTRACT_STMT=", Contract Release"
  COMP_HDR="Contract Release: the Software is, or includes, smart contracts (see Contracts, below)"
  if [ "$RELEASE" != 1 ]; then
    echo "Note: a Contract Release cannot show the Section 9 step in a contract. Your front ends and tools must, and the notice in the Contracts paragraphs goes at the top of each Source file." >&2
  fi
fi

if [ "$RELEASE" = 1 ]; then
  STMT="UFL 3.6, Operational Scope: $DEF_LINE$COMP_STMT$CONTRACT_STMT (LicenseRef-UFL-3.6${SCOPE_SUFFIX})"
  if [ -n "$OUT" ]; then printf '%s\n' "$STMT" > "$OUT"; else printf '%s\n' "$STMT"; fi
  exit 0
fi

if [ -n "$COMPS" ]; then
  SCOPE_LINE="$DEF_LINE (the Software outside the Components below)"
fi
SCOPE_LINE_ESC=$(escape "$SCOPE_LINE")
SCOPE_SUFFIX_ESC=$(escape "$SCOPE_SUFFIX")

FILLED=$(sed \
  -e "s|\[YEAR\]|$YEAR_ESC|g" \
  -e "s|\[COPYRIGHT HOLDER\]|$HOLDER_ESC|g" \
  -e "s|\[PROJECT NAME\]|$PROJECT_ESC|g" \
  -e "s|\[OPERATIONAL SCOPE\]|$SCOPE_LINE_ESC|g" \
  -e "s|LicenseRef-UFL-3.6\`|LicenseRef-UFL-3.6${SCOPE_SUFFIX_ESC}\`|g" \
  -e "s|\`UFL-3.6\`|\`UFL-3.6${SCOPE_SUFFIX_ESC}\`|g" <<'UFL_TEMPLATE'
The Usufruct License (UFL) — Version 3.6
Canonical text, whitepaper, and FAQ: https://github.com/estejosh/UFL-Usufruct-License

Copyright (c) [YEAR] [COPYRIGHT HOLDER]

Operational Scope: [OPERATIONAL SCOPE]

## 1. Grant of Use

Subject to the terms below and the Operational Scope declared above, the
Licensor grants anyone the free, perpetual, worldwide right to use the
Software — in source or compiled form, at any scale — without payment,
except as Section 1A limits that grant. This includes running the
Software, deploying it, integrating with it through its published
interfaces, and operating a product or service built on top of it, as
scoped by Section 1A. A use that Section 1A withholds from the free
grant is licensed under Section 8, on the terms of this license.

## 1A. Operational Scope

The Operational Scope declared above states the only limit, if any, on
Section 1's free grant. Exactly one scope applies to this Software:

[OPERATIONAL SCOPE BODY]

## 1B. Definitions

"Licensor" means the copyright holder named above. "Licensee" means
anyone who uses the Software; when an individual uses it for an
organization, the organization is the Licensee.

"Production Use" means any use of the Software that is not
Non-Production Use. "Non-Production Use" means evaluating, developing,
testing, or demonstrating the Software. It does not include using the
Software on real work or live data for business purposes, or delivering
its output to a court, regulator, client, or customer as finished work.

"Seat" means each individual — employee, contractor, or other personnel
of the Licensee — whose role includes using the Software or relying on
its output in the ordinary course of that role, whether or not that
individual operates the Software. Individuals whose contact with the
Software or its output is incidental or one-time are not Seats. Where a
count of Seats matters under this license, it is the highest number of
Seats at any time during the period being counted.

## 1C. Releases

A "Release" is a version of the Software that the Licensor publishes
under its own version number, tag, or date. This license applies to each
Release separately, and where it refers to the Software, it means the
Release the Licensee uses.

With each Release, the Licensor states which version of this license,
and which Operational Scope, governs that Release (its "Ruling
License"). The statement names both, for example "UFL 3.6, Operational
Scope: Noncommercial", and appears where users get the Release: in its
release notes, its tag, or its package metadata. The Release includes
the full text of its Ruling License. If a Release does not state its
Ruling License, the license text included with it governs; if none is
included, the license text in the Software's repository at the commit
the Release was made from governs.

A Release's Ruling License is fixed when the Release is published. For
that Release, the Licensor grants every Licensee the rights its Ruling
License gives, perpetually and irrevocably, on that Ruling License's own
terms. Nothing the Licensor later does, including publishing a later
Release, changing the license in the Software's repository, or adopting
a later version of this license, changes, narrows, or ends those rights.

The Licensor may license a later Release under a later version of this
license, under a different Operational Scope, or under other terms. A
Licensee who uses that later Release does so under its Ruling License. A
Licensee who keeps using an earlier Release keeps the Ruling License
that Release states.

A Licensor may move the Software to a later version of this license at
any time, for the Releases it publishes after the move, by stating that
version as the Ruling License of each of them. The Licensor gives notice
of the move in the release notes of the first Release under the later
version and wherever else it announces Releases, such as its README,
repository, or website. The notice names the version moved from and the
version moved to, and says what changed in the Operational Scope, if
anything. A Licensor moves only forward: once a Release is published
under a version of this license, no later Release is published under an
earlier version. The one exception is a Release that only patches an
earlier Release for that Release's users, which keeps the earlier
Release's Ruling License. A move changes the Releases made after it and
no earlier Release.

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

  (i) prominently and accurately credits [PROJECT NAME] as the origin of
      the Software or protocol, in its README, whitepaper, or equivalent
      primary documentation; and
  (ii) keeps the canonical-source notice required by Section 7 intact.

Distributing a fork that removes, obscures, or falsifies this
attribution is not permitted under this exception and still requires a
separate license under Section 2(a). This section does not affect
Sections 2(b) or 2(c): incorporating the Software into another
distributed product, and using the Licensor's name or marks to claim
compatibility, still require a separate license regardless of
attribution.

## 2B. Reproducing This License Text

The text of this license — this document itself, independent of any
particular copy's Operational Scope, copyright holder, or project name —
may be freely copied and reproduced by anyone to license their own
software, including verbatim reproduction in a project's own LICENSE
file. This permission is not limited by Section 2(a) and applies
regardless of Operational Scope: licensing your own software under this
text is not "distributing the Software" of any other project that also
uses it, and requires no separate permission from any Licensor who has
used it. This section grants no right to any particular Licensor's
Software — only to the legal text of this license itself.

## 2C. Version Fidelity

The permission granted by Section 2B is a permission to reproduce, not
to modify. A copy of this text is adopted as-is. For each Release
(Section 1C), a Licensor makes two choices and no others: which version
of this license to adopt, and which single Operational Scope in Section
1A applies, stated exactly as that version's canonical text provides for
that scope, including the free threshold the Seat-Limited scope calls
for and the native token, or none, that the Decentralized scope names.
The only blanks a Licensor fills in are the copyright year, the
copyright holder, and the project name given near the top of this text.
Every other term, including the terms on paid use, acceptance, usage
statements, retroactive licenses, and disputes, is set by this text and
is the same for every project under this version. No wording in this
license, including this section, may be added to, removed, or altered in
any copy that is presented, cited, or identified as "the Usufruct
License," "UFL," or by any `LicenseRef-UFL-*` identifier, and no
separate document may add to or change its terms (see Section 15). A
project that needs different terms is free to write its own license,
including one derived from this text under its own name — it is not free
to alter this text and continue to call the result UFL.

Anyone may propose a change for a future version at the canonical source
named in Section 7. An adopted proposal becomes a new official version,
never a retroactive edit: once a version of this license is published,
its text is not changed, and a project that wants a later version's
provisions adopts that version's text in full.

## 2D. Notice Screens

A Licensor may build into the Software a Notice Screen: one short, timed
screen shown when the Software starts, that promotes the Licensor's own
products or services, or those of anyone the Licensor chooses. The
Licensor may apply it to the whole Software or only to named Components.
A Licensor that does this states in the step described in Section 9
which parts of the Software show it, what it is, how long it lasts, and
that it appears only at startup, and the Licensee completes that step
before first use. A Notice Screen is a term of the free grant for the
parts it covers: the Licensee agrees to see it, in exchange for use that
would otherwise cost the Published Price. A Licensee who does not want
to see it can pay the Published Price under Section 8 where the
Published Price allows, and a Licensor may let a paid use end the Notice
Screen.

A Notice Screen must: (a) appear once, at startup, and never again
during that run; (b) end by itself after the time the step states, and
let the user close it sooner by a plain action, including from the
keyboard; (c) never keep the Software from doing its work for longer
than that time; (d) be text, images, or links shipped inside the
Release, with no sound, no flashing, no window outside the Software, and
no link opened unless the user chooses; (e) be labeled as a notice or as
sponsored; (f) stay out of output that machines read, such as exit
codes, logs, and structured data, and out of non-interactive runs; and
(g) involve no ad network, no measurement of who saw or clicked it, and
no network call to show it.

Dark patterns and pop-up nagging are not allowed under this license. A
Notice Screen must not: look like an error, a warning from the system, a
security alert, or part of the Software's own output; hide, disable,
delay, or disguise the way to close it; restart its timer or lengthen
its time after it is closed; use wording that shames, frightens, or
pressures the user; pre-select a purchase or any consent; ask for more
than a plain choice to continue or close; reappear after it is closed,
at any other time, or in a way that grows over time; or collect or send
any data. The Licensor states, to the best of its knowledge, that the
content of each Notice Screen, including content that promotes anyone
else, is lawful and not deceptive, and the Licensor alone is responsible
for that content.

A screen that does not meet this section is not a term of the free
grant. The Licensee has not agreed to it, may remove or disable it,
including in a copy the Licensee distributes, and the Licensor may not
treat doing so as a breach.

Section 10 is unchanged: showing a Notice Screen is never a report of
use, and a Notice Screen is not a way for the Licensor to learn who runs
the Software.

A Licensee will not remove, hide, or alter a Notice Screen that meets
this section, in its own use or in a copy it distributes under Section 2
or 2A, unless the step says that the Licensee may hide it for the
Licensee's own use. This section does not require a Licensor to include
any Notice Screen and does not change any Operational Scope.

## 3. Why "Usufruct"

In civil law, a usufruct is the right to use property belonging to
another and enjoy its benefits, without the right to alter its substance
or transfer ownership to someone else. This license grants exactly that:
full use, no transfer.

## 4. Contributions

A "Contribution" is any fix, change, or addition to the Software that
someone submits to the Licensor, by pull request, patch, message, or any
other means, whether or not the Licensor accepts it.

By submitting a Contribution, its author grants the Licensor a
perpetual, worldwide, irrevocable, royalty-free, non-exclusive license
to use, reproduce, modify, distribute, sublicense, and relicense that
Contribution, as part of the Software or any other work, under this
license or any other terms. The grant includes every patent right the
author holds that the Contribution, or its combination with the
Software, would infringe. Nothing is owed to the author for this
license, now or later. The author keeps ownership of the Contribution.

Submitting a Contribution is the author's agreement to this Section 4.
An author submits only what the author has the right to license: if an
employer, client, or anyone else has rights in a Contribution, the
author must have that party's authority to grant this license before
submitting it.

A Contribution that becomes part of the Software is licensed to everyone
under this license, including the reservations in Section 2.

Where the Licensor requires a recorded step before it will consider a
Contribution, such as a signed acknowledgement in a pull request, the
author will complete it. The step records the author's agreement to this
Section 4 and adds no term to it.

## 5. No Warranty

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT.
IN NO EVENT SHALL THE LICENSOR BE LIABLE FOR ANY CLAIM, DAMAGES, OR
OTHER LIABILITY ARISING FROM THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.

Neither the Licensor nor this license claims that the Software or its
output is accurate, complete, or compliant with any law, regulation,
rule, or standard, or that any court or regulator has approved it.
Output can be wrong or incomplete, and it does not replace review by a
qualified professional.

## 6. Note on Classification

This is a source-available license, not an OSI-approved open source
license. The Open Source Definition requires unrestricted redistribution
rights, which Section 2 intentionally withholds regardless of
Operational Scope. Some Operational Scopes under Section 1A also
withhold uses the Open Source Definition requires to be unrestricted.
The source is public; which uses are free depends on the Operational
Scope declared above, and Section 8 sets how any other use is licensed.

## 7. Notice

The canonical-source line at the top of this license text (or an
equivalent pointer to https://github.com/estejosh/UFL-Usufruct-License)
must be kept intact when this license text is copied into another
project. This is a notice requirement on the license text itself, not an
additional condition on using the Software.

## 8. Paid Use

A use that the Operational Scope withholds from Section 1's free grant
("Paid Use") is licensed under this license, on all of its terms, when
the Licensee pays the Licensor's Published Price for it. The "Published
Price" is the price the Licensor publishes for that use at a location
identified in the Software's repository or documentation. It may be set
per Seat, per device, per year, by tier, or by any other measure, but it
is a price only: it cannot add to, remove, or change any term of this
license.

Paid Use is licensed for the period the Published Price covers and
renews at the Published Price in effect when the next period begins. A
change to the Published Price applies only to periods that begin after
the change. If the Licensor has not published a price for a withheld
use, that use is not available under this license.

A Licensor may build a part of the Software that is Paid Use so that it
does not run until the Licensee enters a valid license key (a "key").
The Software checks the key on the Licensee's own machine, without any
network call, as Section 10 requires. A key is issued to the Licensee
for the period the Published Price covers, may expire when that period
ends, and may be reissued a limited number of times in a period, as the
Published Price states. A Licensee will not use a key outside the Seats
or devices the Published Price covers, will not use a key issued to
someone else, and will not bypass, patch, disable, or forge the check or
a key. A part built this way is not used until a valid key is entered.
Nothing in this license requires a Licensor to build any part this way.

## 9. Acceptance

Using the Software is acceptance of this license. Where the Operational
Scope withholds any use, or sets its own limit of liability and dispute
process (as the Decentralized scope does), the Software presents, before
first use, an affirmative step that names this license's version and
Operational Scope, shows any such limit and process, and must be
completed: an on-screen agreement, an interactive prompt, or, for
non-interactive use, an explicit setting or flag naming the version.
Under any other Operational Scope, the Licensor may build in the same
step. Where the Software provides that step, the Licensee will complete
it and will not bypass it. The Software may record the license version
accepted, the time, and the name of the accepting party, and keeps that
record only on the Licensee's own systems.

In accepting this license, the Licensee acknowledges that the Software
is protected by copyright from its creation, whether or not that
copyright is registered, and that any use the Operational Scope
withholds, made without Paid Use or a Retroactive License covering it,
is use of a copyrighted work outside this license. Nothing in this
license limits the Licensor's rights and remedies under copyright law.

## 10. Usage Statements

Where the Operational Scope withholds any use, the Licensee will, within
30 days of the Licensor's written request and no more than once in any
12 months, give the Licensor a statement signed by a person authorized
to act for the Licensee. The statement gives the period covered; whether
the Licensee made any use the Operational Scope withholds during that
period and, if so, its extent, measured the way the Published Price
measures it (for example, in Seats); and any counts of work processed
that the Software keeps. It contains no content of any data the Software
processed and no identity of the Licensee's clients or customers. The
Software may provide a command that produces the statement from its
local records.

This license does not require or permit the Software to send information
about the Licensee's use to the Licensor for the purpose of enforcing
this license. Compliance is shown by the statement in this section, not
by monitoring.

## 11. Output Marks

The Software may embed technical marks in its output showing that the
Software produced it and whether it was produced under Paid Use, free
Production Use, or Non-Production Use. A mark may not contain the
Licensee's identity or the content of any data the Software processed,
and may not change the substance of any output. This section discloses
those marks to every Licensee. The Licensee will not remove, alter, or
forge them.

## 12. Retroactive Licenses

Use that the Operational Scope withholds, made without Paid Use covering
it, is licensed retroactively once the Licensee pays the following for
each period of that use (a "Retroactive License"):

  (a) the Published Price in effect at the start of that period, if the
      Licensee disclosed the use to the Licensor in writing before the
      Licensor gave the Licensee written notice of it; or
  (b) three times that Published Price, if it did not;

plus simple interest at 10 percent per year, or the highest rate the law
allows if that is lower, from the end of each period until paid. A
Retroactive License reaches back no more than three years before the
earlier of the Licensee's disclosure or the Licensor's notice.

The Published Price is the price of a license taken up front or
disclosed promptly. A Retroactive License covers use the Licensor had to
find, and its price reflects that. These amounts are prices for
licenses, fixed in advance by this license and the same for every
Licensee; they are not damages. Once paid, the use they cover is
licensed as Paid Use.

## 13. Continued Use

The grant in Section 1 is perpetual and is not revoked for nonpayment. A
Licensee that owes amounts under Section 8 or Section 12 keeps its
rights under Section 1 and may keep using the Software. It remains
liable for those amounts, which continue to accrue under Section 12 for
any continued use the Operational Scope withholds, until it is brought
current, either by paying them or by a written agreement with the
Licensor on how and when they will be paid. Once current, the Licensee
continues under this license as before. This section does not limit the
Licensor's remedies for conduct that Section 2 reserves.

## 14. Disputes

This license is governed by California law, without regard to its
conflict-of-laws rules, unless the Operational Scope states otherwise.

Unless the Operational Scope provides its own dispute process, mediation
and arbitration under this section cover a dispute between the Licensor
and a Licensee about whether a use is Paid Use, about any amount owed
under Section 8, 12, or 13, or about a usage statement under Section 10
(a "Payment Dispute"). They do not cover a Licensee's use under Section
1's free grant that raises none of those questions. Any other dispute
arising out of this license or the Software is left to the law and the
courts that would otherwise apply.

A Payment Dispute goes first to mediation. Either party may start
mediation by written notice to the other, and the mediation must begin
within 30 days of that notice. If the dispute is not resolved within 60
days of the notice, either party may submit it to binding arbitration
under the Rules of Arbitration of the International Chamber of Commerce,
before a single arbitrator seated in California. The parties may agree
in writing to a different schedule.

Mediation and arbitration may be conducted entirely by video conference
and electronic submission, and no party is required to attend in person
unless the parties agree otherwise. Judgment on an arbitration award may
be entered in any court with jurisdiction.

Either party may go directly to court for an injunction to stop conduct
that Section 2 reserves or that infringes the Licensor's intellectual
property, without first mediating or arbitrating.

Unless the Operational Scope provides its own rule on costs, in any
arbitration or court proceeding under this license, the prevailing party
is entitled to its reasonable attorney fees and costs.

## 15. Entire License

This license is the complete set of terms on which the Software is used.
No other document, including any document the Licensor publishes, adds
to, removes, or changes these terms. A Published Price sets an amount
only. The only other agreements this license recognizes are a written
agreement under Section 13 on paying amounts already owed, an author's
recorded acknowledgement of Section 4, and a separate license for the
rights Section 2 reserves, which this license does not grant.

If any provision of this license is held unenforceable, the remaining
provisions stay in effect, and the unenforceable provision is enforced
to the greatest extent the law allows.

---
SPDX identifier: UFL is not on the official SPDX license list. Per SPDX
convention for licenses outside that list, use `LicenseRef-UFL-3.6` —
not a bare `UFL-3.6`, which would misrepresent it as SPDX-registered.
UFL_TEMPLATE
)

FILLED=$(printf '%s\n' "$FILLED" | awk -v body="$SCOPE_BODY" -v hdr="$COMP_HDR" '
  $0 == "[OPERATIONAL SCOPE BODY]" { print body; next }
  /^Operational Scope: / && !done { print; if (hdr != "") print hdr; done = 1; next }
  { print }
')

if [ -n "$OUT" ]; then
  printf '%s\n' "$FILLED" > "$OUT"
else
  printf '%s\n' "$FILLED"
fi
