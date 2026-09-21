# Changelog

Notable changes to the Usufruct License (UFL) text itself. This tracks
revisions to the license, not to this repository's tooling or docs — see
the repository's own commit history for those.

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
