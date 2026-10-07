# Worked example: free detector, paid fixer (UFL 3.6 Components)

Snifrig ships two parts in one repository. The monitor and detector are
free for everyone. The fixer, which remediates what the detector finds,
is not free: every production use of it needs Paid Use at the Published
Price, home users included.

```
snifrig/
  LICENSE                 <- one file, generated (below)
  detect/                 <- free core (Operational Scope: Unconditional)
  fix/                    <- paid Component "snifrig-fix"
  crates/snifrig-fix/     <- also part of "snifrig-fix"
  PRICING.md              <- where the Published Price for snifrig-fix is published
```

## Generate the license

```sh
sh generate.sh -y 2026 -c "Snifrig Holder" -p Snifrig -s unconditional \
  -C "snifrig-fix=paid:fix/**,crates/snifrig-fix" -o LICENSE
sh generate.sh -r -s unconditional -C "snifrig-fix=paid:fix/**,crates/snifrig-fix"
```

The second command prints the Release statement (Section 1C) to publish
with each Release:

```
UFL 3.6, Operational Scope: Unconditional; Component snifrig-fix: Paid (LicenseRef-UFL-3.6-U.P-snifrig-fix)
```

[`LICENSE`](./LICENSE) in this folder is that output, with estejosh as the
copyright holder. Use the SPDX identifier
`LicenseRef-UFL-3.6-U.P-snifrig-fix` in package metadata for every package
in the repository, the free ones too: one LICENSE file governs them all.

## What each kind of user owes

| User | Runs | Owes |
|---|---|---|
| Home user with the detector only | `detect/` | Nothing. |
| Anyone, even to try it | `fix/` | Paid Use at the Published Price. Nothing is free except reading the source, so Snifrig publishes a trial price (zero, 14 days) for trial keys. |
| Home user who runs the fixer on a real machine | `fix/` | Paid Use at the Published Price for `snifrig-fix`. |
| Company that runs the fixer in production | `fix/` | The same, measured the way the Published Price measures it (Section 8). |
| Anyone who only has the fixer's source or binary on disk, never run | nothing | Nothing. Code that is present but never run is not used. |

Snifrig's rule: no fixer until paid. Sniffing is always free. Another
product might ship a limited free demo Component instead.

Paying for `snifrig-fix` covers only `snifrig-fix`. The detector needs no
payment either way.

## The acceptance step (Section 9)

The detector shows a Section 9 step only because Snifrig uses a Notice
Screen (Section 2D). It states that the detector shows one line at startup,
for at most 8 seconds, that the user can close it sooner, that it appears
once per run, and that it never appears in `--quiet`, JSON, or CI runs. The
line may promote the author's other projects, or clients who agreed to be
named, labeled as a notice. No network call is made to show it. It is the
price of the free detector, and `fix/` has none because it is paid.
Before `fix/` first runs, the Software shows,
and the user completes:

```
Snifrig-fix is licensed under UFL 3.6 (LicenseRef-UFL-3.6-U.P-snifrig-fix).
Component: snifrig-fix    Operational Scope: Paid
Production use needs Paid Use at the Published Price: https://example.com/snifrig/pricing
Type "I accept" to continue. No key found: the fixer will not run.
```

It names the version, the Component and its scope, and shows where the
Published Price is published. The record (version, Component, time) stays
on the user's own machine.

## Checking payment offline

[`offline-key/`](./offline-key) is a reference design: the Licensor signs a
small key with Ed25519 after payment, and the Software checks it with an
embedded public key, the local clock, and a local machine hash. No network
call is made at any point, so Section 10 is intact.

- Keys are short-lived (30 days here). The Licensee signs in to its account
  on the Snifrig website and downloads a fresh key, up to five times per paid
  period. That is the Licensee's own request, not the Software reporting.
- A key can be bound to the machine the Licensee asked it for.
- The Software refuses a clock set backwards.
- Each key period also unlocks the latest fix recipes, so a cracked binary
  goes stale.

No scheme stops a determined cracker, and this does not claim to. It keeps
honest users honest and makes sharing a key a bad deal. See the Components
section of the whitepaper.

## The PDF

A project that adopts 3.5 includes, in its repository, the PDF of its own
license next to `LICENSE`:

```sh
python3 src/make_pdfs.py --one LICENSE LICENSE.pdf
```
