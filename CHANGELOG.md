# Changelog

Notable changes to the Usufruct License (UFL) text itself. This tracks
revisions to the license, not to this repository's tooling or docs — see
the repository's own commit history for those.

## 3.3 — October 2026

Section 14 now covers payment disputes, not every use. Through 3.2 it
sent any dispute "arising out of this license or the Software" to
mediation and arbitration in California, which bound every user,
including one who only runs the software on the free grant and owes
nothing. For a decentralized project with users in many countries, that
was the wrong reach.

- Mediation and arbitration cover a "Payment Dispute": whether a use is
  Paid Use, an amount owed under Section 8, 12, or 13, or a usage
  statement under Section 10.
- A Licensee's use under the free grant that raises none of those
  questions is not covered. Any other dispute is left to the law and
  courts that would otherwise apply.
- Arbitration is under the Rules of Arbitration of the International
  Chamber of Commerce, by a single arbitrator, still seated in
  California, with California governing law.
- Unchanged: the 30-day mediation start and 60-day arbitration trigger,
  video conduct, court injunctions for Section 2 conduct, and fees to the
  prevailing party.

New Operational Scope: **Decentralized** (suffix `-D`, tag `UFL-D-1a`),
for software released to the public with no owner able to run a normal
dispute process. It is the Unconditional free grant with no Paid Use, so
Sections 8 through 13 do not operate. Under it:

- Every dispute from use goes exclusively to online ICC arbitration
  before a single arbitrator, on an individual basis, not as a class or
  collective action. No party consents to any court's jurisdiction by
  using the Software.
- The arbitrator applies the UNIDROIT Principles of International
  Commercial Contracts and, for anything they do not answer, California
  law. Section 14's California-law sentence now yields to the scope.
- Each party's total liability to the other is limited, to the extent
  the law allows, to one US dollar in value. The paying party chooses
  money or, if the project names a native token, that token valued at one
  dollar at its market price when paid, and the party being paid must
  accept the token if it is chosen. The payer pays in the token by
  written notice that payment is available; if no wallet address is
  given within 90 days of the notice, the payment is complete. If the
  token is unlisted (no exchange or public price source publishes a
  price for it), one token is treated as worth one US dollar. If it
  cannot be delivered for any other reason, payment is one US dollar in
  money, and the payee bears the cost of the wire or transfer, which the
  payer may deduct. The cap is mutual, so it limits the Licensor's
  money claims too.
- Before first use, the Software requires the affirmative step in
  Section 9, which now also applies to this scope and shows the limit of
  liability and dispute process. Completing it is the Licensee's
  agreement to them.
- A modified version, fork, or independent reimplementation is not the
  Software for this scope. Whoever creates, distributes, or uses one does
  so entirely at their own risk, and the Licensor has no liability for
  it, including the one dollar.
- Nothing limits liability the law does not allow to be limited, waives
  a non-waivable right, or stops either party seeking a court injunction
  against conduct Section 2 reserves or that infringes the Licensor's
  intellectual property.

The native token is a fill point for this scope, like the seat threshold
for Seat-Limited. It is optional and defaults to "none". `generate.sh`
and `generate.js` take it with `-k`. Section 2C names it among the
things a Licensor may fill.

Section 9's affirmative step now also applies where a scope sets its own
limit of liability and dispute process. Every other section is the same
as 3.2 apart from version strings.
SPDX identifier: `LicenseRef-UFL-3.3`, with the same `-C`, `-H`, `-N`,
`-S` suffixes. Projects on 1.0 through 3.2 are unaffected unless they
adopt 3.3.

## 3.2 — October 2026

Adds Section 1C, Releases. A project can now move to a newer version of
this license, or a different Operational Scope, for later versions of its
software, and still keep every earlier version of the software on the
terms it was released under.

With each Release the Licensor states which version of UFL, and which
Operational Scope, is that Release's Ruling License. The statement is
fixed when the Release is published. For that Release, the Licensor
grants the rights its Ruling License gives, perpetually and irrevocably,
on that Ruling License's own terms. Nothing done later, including
changing the repository's license or publishing a newer Release, narrows
or ends them. If a Release states nothing, the license text included with
it governs, or failing that the text in the repository at the commit it
was made from.

Section 2C now says a Licensor makes its two choices (version and
Operational Scope) for each Release rather than once. The text of every
other section is unchanged from 3.1 apart from version strings.

Why: through 3.1 a project adopted one version and one scope for the whole
project, and the license said nothing about which terms a given release
carries once the project's license changes. Users of an old release had
only the commit history to show which terms applied to it.

`generate.sh` and `generate.js` gain `-r` (`--release-statement` in the
JS version), which prints the line to publish with a Release, for example
`UFL 3.2, Operational Scope: Noncommercial (LicenseRef-UFL-3.2-N)`. It
needs no year, holder, or project. SPDX identifier: `LicenseRef-UFL-3.2`,
with the same `-C`, `-H`, `-N`, `-S` suffixes.

This is a choice the Licensor makes, not the user. It is not an "or any
later version" grant: a Licensee never moves to a later version on their
own.

Projects on 1.0 through 3.1 are unaffected unless they adopt 3.2.

## 3.1 — October 2026

Section 4 now says what a contributor gives the project. Through 3.0 it
accepted contributions "under these same terms" and granted them back to
the Licensor only "to the extent necessary to keep this license
enforceable," which does not cover relicensing a fix, patents, or whether
the author had the right to submit it. A project that lives on its users'
fixes needed more, and the terms had to be in the license: Section 15
means a separate CLA document cannot add terms of its own.

- **Section 4, Contributions.** A "Contribution" is any fix, change, or
  addition submitted to the Licensor by any means, accepted or not. By
  submitting it, the author grants the Licensor a perpetual, worldwide,
  irrevocable, royalty-free, non-exclusive license to use, reproduce,
  modify, distribute, sublicense, and relicense it, under this license or
  any other terms, including the author's patent rights in it. Nothing is
  owed to the author. The author keeps ownership. Submitting is the
  author's agreement to Section 4, and the author must have the right (or
  the employer's or client's authority) to license what is submitted. A
  Contribution that becomes part of the Software is licensed to everyone
  under this license, Section 2's reservations included. Where the Licensor
  requires a recorded step before considering a Contribution, such as a
  signed acknowledgement in a pull request, the author completes it; the
  step records agreement to Section 4 and adds no term.
- **Section 15, Entire License.** Adds the author's recorded
  acknowledgement of Section 4 to the short list of agreements the license
  recognizes, so a CLA check is consistent with "no other document adds
  terms."

Nothing else in the license text changes. Sections 1 through 3 and 5
through 14 are word for word as in 3.0 apart from the version line and the
SPDX identifier (`LicenseRef-UFL-3.1`, same `-C`, `-H`, `-N`, `-S`
suffixes).

New, and not part of the license text: `templates/cla/`, a kit for
enforcing Section 4 on GitHub (a CLA check as a required status check,
signed commits, and a one-time setup script). The kit records agreement to
Section 4 and adds no term. It means something only under 3.1 or later.

Projects on 1.0 through 3.0 are unaffected unless they adopt 3.1.

## 3.0 — October 2026

Paid use is now part of the license itself. Four of the five Operational
Scopes withhold something from the free grant (a seat threshold,
commercial use, third-party hosting, a competing service). Through 2.2,
the license said those uses needed "a separate written license" and
stopped there, leaving every Licensor to invent the rest in side
documents. 3.0 writes the rest into the text, the same for every project:

- **Section 1B, Definitions.** Licensee, Production Use, Non-Production
  Use, and Seat (counted by role, not by who runs the Software).
- **Section 8, Paid Use.** A withheld use is licensed under UFL itself,
  on all of its terms, at the Licensor's Published Price. A price is
  only a price: it cannot add or change a term.
- **Section 9, Acceptance.** Using the Software is acceptance. Scoped
  projects must present an affirmative click-through or prompt naming
  the version before first use, recorded only on the Licensee's
  systems. The Licensee acknowledges the Software is under copyright
  whether or not registered, and that withheld use without a license
  is use outside the license.
- **Section 10, Usage Statements.** For scoped projects, a signed,
  content-free usage statement on request, at most once a year. The
  license never requires or permits the Software to report use to the
  Licensor for enforcement.
- **Section 11, Output Marks.** Disclosed, non-identifying marks showing
  what produced an output and under which license state.
- **Section 12, Retroactive Licenses.** Use beyond the scope without
  paying is licensed after the fact at the Published Price if the
  Licensee discloses it first, or three times the Published Price if the
  Licensor finds it, plus interest, with a three-year lookback.
- **Section 13, Continued Use.** Section 1's grant is never revoked for
  nonpayment. A Licensee that owes money keeps using the Software and
  is brought current by paying or by a written payment agreement.
- **Section 14, Disputes.** California law; mediation within 30 days,
  then binding arbitration in California after 60 days; both may be
  held entirely by video; court injunctions remain available for
  conduct Section 2 reserves.
- **Section 15, Entire License.** No other document adds to or changes
  the license. There is no addendum.

Section 5 adds that neither the Licensor nor the license claims the
Software's output is accurate, complete, or compliant. Section 2C now
states the rule plainly: a Licensor chooses a version and one
Operational Scope, fills in three blanks, and nothing else. The
Noncommercial, Seat-Limited, No-Third-Party-Hosting, and
No-Competing-Service scope texts now point to Section 8 instead of to
"a separate written license."

Projects on 1.0 through 2.2 are unaffected unless they adopt 3.0. A
project that moves to 3.0 and today keeps pricing or terms in a
separate file (for example a `COMMERCIAL.md`) should reduce that file to
a price list, since Section 15 gives terms in any other document no
effect.

## 2.2 — September 2026

Tightened Section 2B and added Section 2C: Version Fidelity. Section 2B's
permission to reproduce the license text was worded to also allow it to be
"adapted" — that word is removed. Reproducing this text has never included
a license to rewrite it, and 2.2 makes that explicit: a copy of this
license may only be filled in ([YEAR], [COPYRIGHT HOLDER], [PROJECT NAME])
and given exactly one Operational Scope from the canonical menu in
Section 1A, stated exactly as that scope's text provides. Nothing else in
Sections 1 through 7 may be added to, removed, or altered in a copy that
is still called "the Usufruct License," "UFL," or cited by a
`LicenseRef-UFL-*` identifier.

This is a stance, not just a wording fix: UFL is meant to mean the same
thing everywhere it's used, so it isn't something a project can privately
edit and still call UFL. A project that wants different terms writes its
own license — including a fork of this one under a different name — or
proposes the change here for a future official version. Proposals are
welcome at the canonical source (Section 7); adopted ones become a new
version, never a retroactive edit to one already published. See also
"Staying current" in the README, which covers the same principle from the
adopter's side: versions are pinned, and nothing is changed after release.

No other section changes. Custodly (1.0) and Hone (1.1) are unaffected.
ferryman, graea, oddsports, agent-comm-channel, and bullship_public — the
2.1 adopters — have had their LICENSE files refreshed to 2.2 text as part
of this release.

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

**Note (2.2):** Section 2B's original wording ("copied, reproduced, and
adapted") is superseded by 2.2 above — reproduction of this text was never
meant to include a license to alter its terms. See 2.2's entry.

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
