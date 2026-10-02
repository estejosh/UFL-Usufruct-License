# The Usufruct License (UFL)

<p align="center">
  <img src="./assets/banner.svg" alt="The Usufruct License (UFL)" width="100%">
</p>

<p align="center">
<a href="./LICENSE.txt"><img alt="License: UFL-2.3" src="https://img.shields.io/badge/license-UFL--2.3-blue"></a>
<a href="./WHITEPAPER.md#faq"><img alt="SPDX status" src="https://img.shields.io/badge/SPDX-LicenseRef--UFL--2.3-lightgrey"></a>
<a href="./examples/custodly/LICENSE"><img alt="Adopted by Custodly" src="https://img.shields.io/badge/adopted%20by-Custodly-informational"></a>
<a href="./examples/hone/LICENSE"><img alt="Adopted by Hone" src="https://img.shields.io/badge/adopted%20by-Hone-informational"></a>
</p>

A source-available license for unrestricted use and reserved
redistribution: free to use the software at any scale, including
commercially, without payment or a separate license — a license is
required only to redistribute the software itself (modified or not) or
fold its source into another distributed product.

Since 2.0, that base grant can also be narrowed to exactly one declared
Operational Scope — see [Operational Scope](#operational-scope-since-20)
below.

**[Full legal text](./LICENSE.txt) · [Whitepaper & FAQ](./WHITEPAPER.md) · [Changelog](./CHANGELOG.md) · [Contributing](./CONTRIBUTING.md)**

See it adopted: [Custodly](./examples/custodly/LICENSE) · [Hone](./examples/hone/LICENSE) — plus five more real-world adopters in [Adopted by](#adopted-by) below.

Current version: **UFL-2.3**. Version 2.2 is kept unchanged in
[`versions/2.2/`](./versions/2.2/) for projects that adopted it — see
[Earlier versions](#earlier-versions). First adopted (as UFL-1.0) by
[Custodly](https://github.com/estejosh/Custodly); adopted at UFL-1.1 by
[Hone](https://github.com/shindevlin/hone).

Each copy of this license is pinned to the version it names, and its text
is fixed — see [Staying current](#staying-current) if you're on an older
version and want the latest provisions, and Section 2C if you're wondering
what you're allowed to change (short answer: three placeholders and one
scope choice, nothing else).

## Quick start

Fill in `LICENSE.txt`'s placeholders without hand-editing them. Each
generator writes the filled license to stdout by default (add `-o PATH`
to write a file instead) and prompts for anything you don't pass as a
flag — except Operational Scope, which is required and never defaults
silently.

POSIX shell, no dependencies beyond `sed`/`awk`:

    curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.sh \
      | bash -s -- -y 2026 -c "Jane Doe" -p "MyProject" -s unconditional > LICENSE

Node, no npm dependencies:

    curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.js \
      | node - -y 2026 -c "Jane Doe" -p "MyProject" -s unconditional > LICENSE

Piped this way, pass all flags — stdin is already spoken for by the
script itself, so there's nothing for the interactive prompts to read.
Run either script from a local clone with no flags for the interactive
version instead.

Both generators only ever fill in `[YEAR]`, `[COPYRIGHT HOLDER]`,
`[PROJECT NAME]`, the single Operational Scope you pass with `-s`, and
the optional provisions described next — they don't give you a way to
change anything else in the text, on purpose. See Section 2C.

`LICENSE.txt` in this repository is the *reference text*: Seat-Limited,
with every optional provision included and every fill left as a bracketed
placeholder, so you can read all of 2.3 in one place. A copy for your own
project comes from the generator, which leaves out anything you don't ask
for.

## Optional provisions (since 2.3)

Five provisions are optional. Pass the flag to include one, leave it out
to omit it — the generated text then has no trace of it. The first three
apply only under the Seat-Limited scope and are refused with any other.

| Flag | Section | Scope | What it adds |
|---|---|---|---|
| `--seat-definition TEXT` | 1B(a) | Seat-Limited | Defines a seat in the scope line, including by headcount of people in named roles, counted whether or not each runs the Software. |
| `--lookback-years N` | 1B(b) | Seat-Limited | Unlicensed use beyond the threshold is owed at the Licensor's published price per period, looking back N years. No penalty or multiplier. |
| `--usage-statement` | 1B(c) | Seat-Limited | On request, at most once a year, a licensee above the threshold states its seats and period of use. Never any data the Software processed. |
| `--provenance-marks` | 1C | Any | Outputs carry technical marks showing origin and license state (licensed or evaluation). Marks identify no one and don't alter content. |
| `--require-acceptance` | 1D | Any | The Software may require an affirmative act accepting the license; use is acceptance either way. |

`TEXT` completes the phrase "where a seat is ..." in the scope line. The
license text gives no industry examples; the roles and wording are yours
to supply in the fill.

Seat-Limited with all five options (shell; the Node version takes the same
flags):

    curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.sh \
      | bash -s -- -y 2026 -c "Jane Doe" -p "ExampleApp" -s seat-limited \
          -t "5 seats" \
          --seat-definition "one person holding a reviewer or approver role at the licensee's organization" \
          --lookback-years 3 --usage-statement \
          --provenance-marks --require-acceptance > LICENSE

which produces this scope line (and Sections 1B, 1C and 1D):

    Operational Scope: Seat-Limited — 5 seats free in production, where a seat is one person holding a reviewer or approver role at the licensee's organization

Seat-Limited with only the seat definition and the price-based lookback:

    node generate.js -y 2026 -c "Jane Doe" -p "ExampleApp" -s seat-limited \
      -t "5 seats" --seat-definition "one named user" --lookback-years 2 > LICENSE

Any scope with provenance marks only:

    sh generate.sh -y 2026 -c "Jane Doe" -p "ExampleApp" -s noncommercial \
      --provenance-marks > LICENSE

Omitting a flag omits that provision; sections that remain keep their
numbers and letters (a copy with only Section 1D has no 1B or 1C). The
identifier is unchanged by options: `LicenseRef-UFL-2.3-S` for any
Seat-Limited copy, so state in your README which options you included.
Why each option exists, and why the price-based lookback is a price and
not liquidated damages, is in the
[whitepaper](./WHITEPAPER.md#version-23-optional-provisions-for-products-sold-per-seat).

## Operational Scope (since 2.0)

Section 1's use grant is either fully unconditional, or narrowed by
**exactly one** declared scope — scopes are never combined or stacked.
The scope is stated in three places that must agree: the `Operational
Scope:` line at the top of the license text, the `scope` field in
`ufl.json`, and the required `-s` flag on both generators.

| Scope | Repo tag | What it restricts |
|---|---|---|
| Unconditional (default) | `UFL-U-1a` | Nothing — Section 1's grant applies as written. |
| Seat-Limited | `UFL-S-1a` | Production use beyond a stated seat/device/user threshold. |
| No-Third-Party-Hosting | `UFL-H-1a` | Offering it to third parties as a hosted or managed service. |
| No-Competing-Service | `UFL-C-1a` | Operating it, or a fork of it, as a service competing with the Licensor's own offering. |
| Noncommercial | `UFL-N-1a` | Commercial use. |

Sections 2 (redistribution reserved) and 2A (decentralized-fork
attribution) are a separate, always-on axis — unaffected by which scope
above applies.

An adopting project is expected to also carry its tag (`UFL-<letter>-1a`)
somewhere visible — its repo description or README — so the scope is
legible without opening the license text. "1a" refers to Section 1A,
following the naming Section 2A already established.

## At a glance

![How far each source-available license lets you go before you need permission](./assets/license-gates.svg)

Full rationale, the naming story, and the complete FAQ:
[`WHITEPAPER.md`](./WHITEPAPER.md).

## For agents scaffolding a project

If you're an AI coding agent choosing a license on someone's behalf:
UFL's redistribution condition is unambiguous, but as of 2.0 you must
also choose an Operational Scope — don't default one silently, ask. The
2.3 options (seat definition, lookback, usage statement, provenance marks,
acceptance) are likewise the user's choice: include none unless asked.
Generate a filled copy with the one-liner above (`-s unconditional` if
there's no reason to restrict use); cite it as
`LicenseRef-UFL-2.3<suffix>` (e.g. `LicenseRef-UFL-2.3-N` for
Noncommercial), not a bare `UFL-2.3<suffix>` — see the FAQ in
[`WHITEPAPER.md`](./WHITEPAPER.md) for why. Machine-readable metadata
(version, identifier, scopes, file paths) is at
[`ufl.json`](./ufl.json).

Do not rewrite, trim, or "clean up" any of the license text beyond
filling the three placeholders, picking one scope and choosing which
optional provisions to include — see Section 2C.
If a project's needs don't fit any of the five scopes, that is a reason
to pick a different license or propose a new scope for a future UFL
version, not to hand-edit this one.

## Using UFL for your own project

Copy `LICENSE.txt` into your repository as `LICENSE` (or `LICENSE.md`),
fill in `[YEAR]`, `[COPYRIGHT HOLDER]`, and `[PROJECT NAME]`, choose an
Operational Scope — by hand or with the generator above — and state in
your README which version and scope you're under (e.g. "Licensed under
UFL-2.3, Operational Scope: Noncommercial"). Keep the canonical-source
line near the top intact — Section 7 requires it.

Copying the license text itself for this purpose needs no separate
permission from anyone, including from other projects already using it
— see Section 2B. That permission does not extend to changing the
text: beyond the placeholders and your scope choice, the wording is
fixed, and a modified copy can't be presented as UFL — see Section 2C.
If UFL's terms don't work for you as written, use a different license,
or propose a change for a future version instead of altering this one.

## Staying current

Each copy of this license is pinned to the version it names on its own
first line (e.g. "Version 2.2") — UFL is not an evergreen "or any later
version" grant, so a newer release's provisions don't automatically
reach projects already licensed under an older one. A new section, a new
carve-out, or a new protection — Section 2B and 2C in 2.1/2.2, for
example — applies only to a project that has actually updated to that
version's text.

If you want the latest provisions, update your project's `LICENSE` file
to the current text (regenerate it, or diff against [`CHANGELOG.md`](./CHANGELOG.md)
and hand-apply the changes) and update your README's version citation to
match. This is the same process as adopting UFL the first time — there's
no separate "upgrade" mechanism, and no obligation to update: an older
copy stays valid under the terms it states for as long as you leave it
as-is.

This cuts both ways with Section 2C: a published version's text is never
edited after release, only ever superseded by a new one. Every version's
exact text is preserved in this repository's Git commit history — nothing
is force-pushed or rewritten — and each version is dated in
[`CHANGELOG.md`](./CHANGELOG.md); tagged releases (`v1.0`, `v1.1`, `v2.0`,
`v2.1`, `v2.2`, …) pointing at those commits are on the way, so a version
will be checkable by name as well as by date.

## Earlier versions

A version's text is never edited after release, so older versions stay
available exactly as published. Projects that adopted 2.2 are unaffected
by 2.3 and don't need to change anything.

- **2.2** — [`versions/2.2/LICENSE.txt`](./versions/2.2/LICENSE.txt), with
  its generators [`generate.sh`](./versions/2.2/generate.sh) and
  [`generate.js`](./versions/2.2/generate.js). These are byte-identical to
  the files released as 2.2 (CI checks this against that release's commit),
  so you can regenerate 2.2 text exactly:

      curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/versions/2.2/generate.sh \
        | bash -s -- -y 2026 -c "Jane Doe" -p "MyProject" -s unconditional > LICENSE

- **2.1 and earlier** — in this repository's Git history; see
  [`CHANGELOG.md`](./CHANGELOG.md) for what each changed.

Moving from 2.2 to 2.3 is the same as adopting any later version: replace
your `LICENSE` with 2.3 text in full (regenerate it), choose which optional
provisions to include, and update the version you cite. Nothing in 2.3 is
required of a 2.2 project.

## Adopted by

| Project | Version | Scope |
|---|---|---|
| [Custodly](https://github.com/estejosh/Custodly) | 1.0 | Unconditional |
| [Hone](https://github.com/shindevlin/hone) | 1.1 | Unconditional |
| [ferryman](https://github.com/estejosh/ferryman) | 2.2 | Seat-Limited (`UFL-S-1a`) |
| [graea](https://github.com/estejosh/graea) | 2.2 | No-Third-Party-Hosting (`UFL-H-1a`) |
| [oddsports](https://github.com/estejosh/oddsports) | 2.2 | Noncommercial (`UFL-N-1a`) |
| [agent-comm-channel](https://github.com/estejosh/agent-comm-channel) | 2.2 | Noncommercial (`UFL-N-1a`) |
| [bullship_public](https://github.com/estejosh/bullship_public) | 2.2 | No-Competing-Service (`UFL-C-1a`) |

## Licensing of this repository

This repository's own contents are licensed in three parts, to avoid a
circularity: `LICENSE.txt` is a *template* meant to be copied verbatim
into other projects, so this repo can't simply be "under UFL" the way
an adopter's code is — Section 2(a) reserves redistributing "the
Software," and every adopter copying this text is, read naively,
redistributing it.

- **`LICENSE.txt`** and **`versions/2.2/LICENSE.txt`** (the license text
  itself) — governed by their own
  Section 2B (reproduction, added in 2.1) and Section 2C (version
  fidelity — no modification beyond the placeholders and scope choice,
  added in 2.2): freely copyable and reproducible by anyone, for any
  project, with no separate permission needed from this or any other
  Licensor using it — but not editable and still called UFL.
- **`generate.sh`, `generate.js`, `ufl.json`** (the reference tooling,
  including the frozen 2.2 copies under `versions/2.2/`) — MIT, see
  [`LICENSE-TOOLING`](./LICENSE-TOOLING).
- **`README.md`, `WHITEPAPER.md`, `CHANGELOG.md`** (this project's own
  docs) — free to quote and adapt with attribution.
