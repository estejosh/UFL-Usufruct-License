# Changelog

Notable changes to the Usufruct License (UFL) text itself. This tracks
revisions to the license, not to this repository's tooling or docs — see
the repository's own commit history for those.

## 2.1 — September 2026

Added Section 2B: reproducing this license text. The UFL template itself —
independent of any particular copy's Operational Scope, copyright holder,
or project name — may now be freely copied, reproduced, and adapted by
anyone to license their own software, including verbatim reproduction in a
project's own LICENSE file. This is not limited by Section 2(a) and applies
regardless of Operational Scope.

This closes a self-referential gap: this repository's own `LICENSE.txt` is
the UFL template, so without an explicit carve-out, Section 2(a)'s
reservation on "distributing the Software" could be read as restricting
exactly the copying this project depends on — every adopter's LICENSE file
is a reproduction of this text. Section 2B makes explicit what the project
already required to function, and is scoped narrowly: it grants reuse of
the license *text*, not of any Licensor's actual Software.

This repository also now separates its own licensing three ways, since the
same self-reference applies to hosting UFL's own reference materials:
`LICENSE.txt` (freely reproducible per Section 2B above), the generator
tooling — `generate.sh`, `generate.js`, `ufl.json` — under a separate MIT
grant (`LICENSE-TOOLING`), and the docs (`README.md`, `WHITEPAPER.md`,
this changelog) freely quotable with attribution.

No other section changes. Custodly (1.0) and Hone (1.1) are unaffected.
ferryman, graea, oddsports, agent-comm-channel, and bullship_public — the
2.0 adopters — have had their LICENSE files refreshed to 2.1 text as part
of this release.

## 2.0 — September 2026

Added Section 1A: Operational Scope. Section 1's use grant is now
declared as exactly one scope, stated on an "Operational Scope:" line
above the license text and mirrored in `ufl.json`:

- **Unconditional** (the default — functionally identical to Section 1
  in 1.x): free use at any scale, including operating a service, with
  no further condition.
- **No-Competing-Service**: free use except operating the Software, or
  a fork of it, as a service competing with the Licensor's own offering.
- **No-Third-Party-Hosting**: free use except providing the Software to
  third parties as a hosted or managed service.
- **Noncommercial**: free for non-commercial use only.
- **Seat-Limited**: free in production up to a stated seat/device/user
  threshold, unlimited free for non-production use.

Section 2 (redistribution reserved) and Section 2A (decentralized-fork
attribution) are unchanged and apply regardless of Operational Scope —
Section 1A is a separate axis. `generate.sh`/`generate.js` gain `-s`
(scope) and `-t` (threshold, seat-limited only) flags; omitting `-s`
still produces the same Unconditional text 1.1 always did. Projects
already on UFL-1.0/1.1 (Custodly, Hone) are unaffected unless they
choose to move to 2.0.

Adopters are expected to also carry their scope as a short repo-level
tag (e.g. `UFL-S-1a` for Seat-Limited) — see the README for the full
tag convention.

## 1.1 — September 2026

Added Section 2A: forks of decentralized or network software (a node,
client, or peer in a blockchain or similar peer-to-peer protocol) no
longer need a separate license under Section 2(a), including to operate
a competing network — provided the fork keeps clear, accurate
attribution to the original project and preserves the Section 7
canonical-source notice. Modeled on how Bitcoin forks are free to
compete as long as they don't hide that they're Bitcoin forks. Sections
2(b) and 2(c) are unaffected. Projects already on UFL-1.0 (e.g.
Custodly) are unaffected unless they choose to adopt 1.1.

## 1.0 — September 2026 — initial release
