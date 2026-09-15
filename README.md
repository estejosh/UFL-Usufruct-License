# The Usufruct License (UFL)

[![License: UFL-1.0](https://img.shields.io/badge/license-UFL--1.0-blue)](./LICENSE.txt)

A source-available license for unrestricted use and reserved
redistribution: free to use the software at any scale, including
commercially, without payment or a separate license — a license is
required only to redistribute the software itself (modified or not) or
fold its source into another distributed product.

- Full legal text: [`LICENSE.txt`](./LICENSE.txt)
- Rationale, comparison to BUSL/SSPL/Elastic/PolyForm, naming story, and
  FAQ: [`WHITEPAPER.md`](./WHITEPAPER.md)
- See it adopted: [Custodly](./examples/custodly/LICENSE)

Current version: **UFL-1.0**. See [`CHANGELOG.md`](./CHANGELOG.md) for
revision history. First adopted by
[Custodly](https://github.com/estejosh/Custodly).

## Quick start

Fill in `LICENSE.txt`'s placeholders without hand-editing them. Each
generator writes the filled license to stdout by default (add `-o PATH`
to write a file instead) and prompts for anything you don't pass as a
flag.

POSIX shell, no dependencies beyond `sed`:

    curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.sh \
      | bash -s -- -y 2026 -c "Jane Doe" -p "MyProject" > LICENSE

Node, no npm dependencies:

    curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.js \
      | node - -y 2026 -c "Jane Doe" -p "MyProject" > LICENSE

Piped this way, pass all three flags — stdin is already spoken for by
the script itself, so there's nothing for the interactive prompts to
read. Run either script from a local clone with no flags for the
interactive version instead.

## Using UFL for your own project

Copy `LICENSE.txt` into your repository as `LICENSE` (or `LICENSE.md`),
fill in `[YEAR]`, `[COPYRIGHT HOLDER]`, and `[PROJECT NAME]` — by hand or
with the generator above — and state in your README which version
you're under (e.g. "Licensed under UFL-1.0"). See
[`CONTRIBUTING.md`](./CONTRIBUTING.md) before proposing changes to the
license text itself.
