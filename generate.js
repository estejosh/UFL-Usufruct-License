#!/usr/bin/env node
// generate.js — fill in a copy of the Usufruct License (UFL) v1.0.
// Single-file Node script, no npm dependencies (built-in `fs` only).
//
// Usage:
//   node generate.js [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] [-o OUTPUT_PATH]
// Any flag left out is prompted for. With no -o, the filled license is
// written to stdout.
//
// Piped from curl — pass every flag, since stdin is the script itself in
// this mode and interactive prompts have nothing to read:
//   curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.js \
//     | node - -y 2026 -c "Jane Doe" -p "MyProject" > LICENSE
//
// Tracks UFL 1.0. See CHANGELOG.md for revisions.

'use strict';

const fs = require('fs');

const TEMPLATE = [
  'The Usufruct License (UFL) — Version 1.0',
  'Canonical text, whitepaper, and FAQ: https://github.com/estejosh/UFL-Usufruct-License',
  '',
  'Copyright (c) [YEAR] [COPYRIGHT HOLDER]',
  '',
  '## 1. Grant of Use',
  '',
  'Subject to the terms below, the Licensor grants anyone the free,',
  'perpetual, worldwide right to use the Software — in source or compiled',
  'form, for any purpose, including commercial purposes, at any scale —',
  'without payment or a separate license. This includes running the',
  'Software, deploying it, integrating with it through its published',
  'interfaces, and operating a product or service built on top of it.',
  '',
  '## 2. Reserved Rights',
  '',
  'The following rights are reserved to the Licensor and are NOT granted by',
  'Section 1. They require a separate written license from the Licensor:',
  '',
  '  (a) Distributing the Software, or any modified version, fork, or',
  '      substantially similar reimplementation of it, to any third party,',
  '      in source or compiled form.',
  '  (b) Incorporating the Software\'s source code into another product or',
  '      service that is distributed, sold, or otherwise made available to',
  '      third parties.',
  '  (c) Using the Licensor\'s name, marks, or claims of compatibility',
  '      ("[PROJECT NAME]-compatible," "built on [PROJECT NAME]," etc.) in',
  '      connection with a distributed derivative.',
  '',
  '## 3. Why "Usufruct"',
  '',
  'In civil law, a usufruct is the right to use property belonging to',
  'another and enjoy its benefits, without the right to alter its substance',
  'or transfer ownership to someone else. This license grants exactly that:',
  'full use, no transfer.',
  '',
  '## 4. Contributions',
  '',
  'Contributions submitted to a Software repository under this license are',
  'accepted under these same terms and are granted back to the Licensor to',
  'the extent necessary to keep this license enforceable across the',
  'combined work.',
  '',
  '## 5. No Warranty',
  '',
  'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS',
  'OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF',
  'MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT.',
  'IN NO EVENT SHALL THE LICENSOR BE LIABLE FOR ANY CLAIM, DAMAGES, OR',
  'OTHER LIABILITY ARISING FROM THE SOFTWARE OR THE USE OR OTHER DEALINGS',
  'IN THE SOFTWARE.',
  '',
  '## 6. Note on Classification',
  '',
  'This is a source-available license, not an OSI-approved open source',
  'license. The Open Source Definition requires unrestricted redistribution',
  'rights, which Section 2 intentionally withholds. The source is public',
  'and free to use at any scale; only redistribution of the Software itself',
  'requires a separate license.',
  '',
  '## 7. Notice',
  '',
  'The canonical-source line at the top of this license text (or an',
  'equivalent pointer to https://github.com/estejosh/UFL-Usufruct-License)',
  'must be kept intact when this license text is copied into another',
  'project. This is a notice requirement on the license text itself, not a',
  'condition on using the Software — Section 1\'s grant is unconditional.',
  '',
  '---',
  'SPDX identifier: UFL is not on the official SPDX license list. Per SPDX',
  'convention for licenses outside that list, use `LicenseRef-UFL-1.0` —',
  'not a bare `UFL-1.0`, which would misrepresent it as SPDX-registered.',
  ''
].join('\n');

function parseArgs(argv) {
  const out = { year: null, holder: null, project: null, out: null };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '-y') { out.year = argv[++i]; }
    else if (a === '-c') { out.holder = argv[++i]; }
    else if (a === '-p') { out.project = argv[++i]; }
    else if (a === '-o') { out.out = argv[++i]; }
    else if (a === '-h' || a === '--help') {
      process.stderr.write(
        'Usage: generate.js [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] [-o OUTPUT_PATH]\n'
      );
      process.exit(0);
    } else {
      process.stderr.write('Unknown argument: ' + a + '\n');
      process.exit(1);
    }
  }
  return out;
}

// Minimal synchronous stdin prompt — no readline, so the whole tool stays
// a single dependency-free file. Only used when a flag is omitted.
function prompt(question) {
  process.stderr.write(question);
  const buf = Buffer.alloc(4096);
  let bytes = 0;
  try {
    bytes = fs.readSync(0, buf, 0, buf.length, null);
  } catch (e) {
    bytes = 0;
  }
  return buf.toString('utf8', 0, bytes).replace(/\r?\n$/, '');
}

function fill(template, year, holder, project) {
  return template
    .split('[YEAR]').join(year)
    .split('[COPYRIGHT HOLDER]').join(holder)
    .split('[PROJECT NAME]').join(project);
}

function main() {
  const args = parseArgs(process.argv.slice(2));

  const year = args.year || prompt('Year: ');
  const holder = args.holder || prompt('Copyright holder: ');
  const project = args.project || prompt('Project name: ');

  const filled = fill(TEMPLATE, year, holder, project);

  if (args.out) {
    fs.writeFileSync(args.out, filled);
  } else {
    process.stdout.write(filled);
  }
}

main();
