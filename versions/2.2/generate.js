#!/usr/bin/env node
// generate.js — fill in a copy of the Usufruct License (UFL) v2.2.
// Single-file Node script, no npm dependencies (built-in `fs` only).
//
// Usage:
//   node generate.js [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] \
//     [-s SCOPE] [-t THRESHOLD] [-o OUTPUT_PATH]
//
// SCOPE is one of: unconditional (default), no-competing-service,
// no-third-party-hosting, noncommercial, seat-limited. THRESHOLD is only
// used (and required) when SCOPE is seat-limited — free text describing
// the free production tier, e.g. "2 seats, 2 computers, 2 mobile devices".
// Any flag left out is prompted for, except THRESHOLD, which is only
// prompted for when SCOPE is seat-limited. With no -o, the filled license
// is written to stdout.
//
// This script fills in the placeholders and picks one Operational Scope —
// it does not otherwise alter the license text. See Section 2C.
//
// Piped from curl — pass every flag, since stdin is the script itself in
// this mode and interactive prompts have nothing to read:
//   curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.js \
//     | node - -y 2026 -c "Jane Doe" -p "MyProject" -s unconditional > LICENSE
//
// Tracks UFL 2.2. See CHANGELOG.md for revisions.

'use strict';

const fs = require('fs');

const TEMPLATE = [
  'The Usufruct License (UFL) — Version 2.2',
  'Canonical text, whitepaper, and FAQ: https://github.com/estejosh/UFL-Usufruct-License',
  '',
  'Copyright (c) [YEAR] [COPYRIGHT HOLDER]',
  '',
  'Operational Scope: [OPERATIONAL SCOPE]',
  '',
  '## 1. Grant of Use',
  '',
  'Subject to the terms below and the Operational Scope declared above,',
  'the Licensor grants anyone the free, perpetual, worldwide right to use',
  'the Software — in source or compiled form, at any scale — without',
  'payment or a separate license beyond what Section 1A requires. This',
  'includes running the Software, deploying it, integrating with it',
  'through its published interfaces, and operating a product or service',
  'built on top of it, as scoped by Section 1A.',
  '',
  '## 1A. Operational Scope',
  '',
  'The Operational Scope declared above states the only limit, if any, on',
  "Section 1's grant. Exactly one scope applies to this Software:",
  '',
  '[OPERATIONAL SCOPE BODY]',
  '',
  '## 2. Reserved Rights',
  '',
  'The following rights are reserved to the Licensor and are NOT granted by',
  'Section 1. They require a separate written license from the Licensor,',
  'except as Section 2A permits:',
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
  '## 2A. Forks of Decentralized or Network Software',
  '',
  'If the Software is designed to run as a node, client, or peer in a',
  'decentralized network, blockchain, or similar peer-to-peer protocol,',
  'Section 2(a) does not require a separate license for distributing a',
  'modified version, fork, or independent reimplementation of it —',
  'including to operate a competing network — provided the distributed',
  'work:',
  '',
  '  (i) prominently and accurately credits [PROJECT NAME] as the origin',
  '      of the Software or protocol, in its README, whitepaper, or',
  '      equivalent primary documentation; and',
  '  (ii) keeps the canonical-source notice required by Section 7 intact.',
  '',
  'Distributing a fork that removes, obscures, or falsifies this',
  'attribution is not permitted under this exception and still requires a',
  'separate license under Section 2(a). This section does not affect',
  'Sections 2(b) or 2(c): incorporating the Software into another',
  'distributed product, and using the Licensor\'s name or marks to claim',
  'compatibility, still require a separate license regardless of',
  'attribution.',
  '',
  '## 2B. Reproducing This License Text',
  '',
  "The text of this license — this document itself, independent of any",
  "particular copy's Operational Scope, copyright holder, or project name —",
  'may be freely copied and reproduced by anyone to license their own',
  "software, including verbatim reproduction in a project's own LICENSE",
  'file. This permission is not limited by Section 2(a) and applies',
  'regardless of Operational Scope: licensing your own software under this',
  'text is not "distributing the Software" of any other project that also',
  'uses it, and requires no separate permission from any Licensor who has',
  "used it. This section grants no right to any particular Licensor's",
  'Software — only to the legal text of this license itself.',
  '',
  '## 2C. Version Fidelity',
  '',
  'The permission granted by Section 2B is a permission to reproduce, not',
  'to modify. A copy of this text is adopted as-is: the only blanks a',
  'Licensor may fill in are the copyright year, the copyright holder, and',
  'the project name given near the top of this text, and the only choice',
  'a Licensor may make is which single Operational Scope in Section 1A',
  'applies, stated exactly as the canonical text provides for that scope.',
  'Beyond those fills, no wording in Sections 1 through 7 of this',
  'license, including this section, may be added to, removed, or altered',
  'in any copy that is presented, cited, or identified as "the Usufruct',
  'License," "UFL," or by any `LicenseRef-UFL-*` identifier. A project',
  "that needs different terms is free to write its own license, including",
  "one derived from this text under its own name — it is not free to",
  'alter this text and continue to call the result UFL.',
  '',
  'Anyone may propose a change for a future version at the canonical',
  'source named in Section 7. An adopted proposal becomes a new official',
  'version, never a retroactive edit: once a version of this license is',
  "published, its text is not changed, and a project that wants a later",
  "version's provisions adopts that version's text in full.",
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
  'rights, which Section 2 intentionally withholds regardless of',
  'Operational Scope. Some Operational Scopes under Section 1A also',
  'withhold uses the Open Source Definition requires to be unrestricted.',
  'The source is public; which uses are free depends on the Operational',
  'Scope declared above.',
  '',
  '## 7. Notice',
  '',
  'The canonical-source line at the top of this license text (or an',
  'equivalent pointer to https://github.com/estejosh/UFL-Usufruct-License)',
  'must be kept intact when this license text is copied into another',
  'project. This is a notice requirement on the license text itself, not',
  'an additional condition on using the Software beyond Section 1A.',
  '',
  '---',
  'SPDX identifier: UFL is not on the official SPDX license list. Per SPDX',
  'convention for licenses outside that list, use `LicenseRef-UFL-2.2` —',
  'not a bare `UFL-2.2`, which would misrepresent it as SPDX-registered.',
  ''
].join('\n');

const SCOPES = {
  'unconditional': {
    line: 'Unconditional',
    suffix: '',
    body: [
      "Unconditional — Section 1's grant is unconditional: it includes",
      'running the Software, deploying it, integrating with it, and operating',
      'a product or service built on top of it, commercially or otherwise, at',
      'any scale, with no further condition.'
    ]
  },
  'no-competing-service': {
    line: 'No-Competing-Service',
    suffix: '-C',
    body: [
      "No-Competing-Service — Section 1's grant excludes operating the",
      'Software, or a modified version or fork of it, as a product or service',
      'offered to third parties in competition with a product or service the',
      'Licensor offers using the Software. All other uses described in',
      'Section 1 are unconditional.'
    ]
  },
  'no-third-party-hosting': {
    line: 'No-Third-Party-Hosting',
    suffix: '-H',
    body: [
      "No-Third-Party-Hosting — Section 1's grant excludes providing the",
      "Software to third parties as a hosted or managed service that gives",
      "those third parties access to substantially all of the Software's",
      'features or functionality. All other uses described in Section 1 are',
      'unconditional.'
    ]
  },
  'noncommercial': {
    line: 'Noncommercial',
    suffix: '-N',
    body: [
      "Noncommercial — Section 1's grant is limited to non-commercial use.",
      'Commercial use of the Software requires a separate written license',
      'from the Licensor.'
    ]
  },
  'seat-limited': {
    // line and body are built dynamically once THRESHOLD is known — see buildScope()
    suffix: '-S'
  }
};

function buildScope(scopeKey, threshold) {
  if (scopeKey === 'seat-limited') {
    return {
      line: 'Seat-Limited — ' + threshold + ' free in production',
      suffix: '-S',
      body: [
        "Seat-Limited — Section 1's grant is unconditional for non-production",
        'use. Production use is free up to ' + threshold + '; production use beyond',
        'that threshold requires a paid, separate written license from the',
        'Licensor.'
      ]
    };
  }
  return SCOPES[scopeKey];
}

function parseArgs(argv) {
  const out = { year: null, holder: null, project: null, scope: 'unconditional', threshold: null, out: null };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '-y') { out.year = argv[++i]; }
    else if (a === '-c') { out.holder = argv[++i]; }
    else if (a === '-p') { out.project = argv[++i]; }
    else if (a === '-s') { out.scope = argv[++i]; }
    else if (a === '-t') { out.threshold = argv[++i]; }
    else if (a === '-o') { out.out = argv[++i]; }
    else if (a === '-h' || a === '--help') {
      process.stderr.write(
        'Usage: generate.js [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] [-s SCOPE] [-t THRESHOLD] [-o OUTPUT_PATH]\n' +
        'SCOPE: unconditional | no-competing-service | no-third-party-hosting | noncommercial | seat-limited\n'
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

function fill(template, year, holder, project, scopeLine, scopeBodyLines, scopeSuffix) {
  const filledBody = scopeBodyLines.join('\n');
  return template
    .split('[YEAR]').join(year)
    .split('[COPYRIGHT HOLDER]').join(holder)
    .split('[PROJECT NAME]').join(project)
    .split('[OPERATIONAL SCOPE BODY]').join(filledBody)
    .split('[OPERATIONAL SCOPE]').join(scopeLine)
    .split('LicenseRef-UFL-2.2`').join('LicenseRef-UFL-2.2' + scopeSuffix + '`')
    .split('`UFL-2.2`').join('`UFL-2.2' + scopeSuffix + '`');
}

function main() {
  const args = parseArgs(process.argv.slice(2));

  const year = args.year || prompt('Year: ');
  const holder = args.holder || prompt('Copyright holder: ');
  const project = args.project || prompt('Project name: ');

  const validScopes = ['unconditional', 'no-competing-service', 'no-third-party-hosting', 'noncommercial', 'seat-limited'];
  if (validScopes.indexOf(args.scope) === -1) {
    process.stderr.write('Unknown SCOPE: ' + args.scope + '\n');
    process.stderr.write('Must be one of: ' + validScopes.join(' | ') + '\n');
    process.exit(1);
  }

  let threshold = args.threshold;
  if (args.scope === 'seat-limited' && !threshold) {
    threshold = prompt('Free production threshold (e.g. "2 seats, 2 computers, 2 mobile devices"): ');
  }

  const scope = buildScope(args.scope, threshold);
  const filled = fill(TEMPLATE, year, holder, project, scope.line, scope.body, scope.suffix);

  if (args.out) {
    fs.writeFileSync(args.out, filled);
  } else {
    process.stdout.write(filled);
  }
}

main();
