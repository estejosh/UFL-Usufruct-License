#!/usr/bin/env node
// generate.js — fill in a copy of the Usufruct License (UFL) v2.3.
// Single-file Node script, no npm dependencies (built-in `fs` only).
//
// Usage:
//   node generate.js [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] \
//     [-s SCOPE] [-t THRESHOLD] [-o OUTPUT_PATH] \
//     [--seat-definition TEXT] [--lookback-years N] [--usage-statement] \
//     [--provenance-marks] [--require-acceptance]
//
// SCOPE is one of: unconditional (default), no-competing-service,
// no-third-party-hosting, noncommercial, seat-limited. THRESHOLD is only
// used (and required) when SCOPE is seat-limited — free text describing
// the free production tier, e.g. "2 seats, 2 computers, 2 mobile devices".
// Any flag left out is prompted for, except THRESHOLD, which is only
// prompted for when SCOPE is seat-limited. With no -o, the filled license
// is written to stdout.
//
// Optional provisions (new in 2.3). Leave a flag out and the text is
// produced without that provision:
//   --seat-definition TEXT   Section 1B(a). Completes "a seat is ..." in
//                            the Operational Scope line. seat-limited only.
//   --lookback-years N       Section 1B(b). Use beyond the threshold is
//                            owed at the published price, looking back N
//                            years. seat-limited only.
//   --usage-statement        Section 1B(c). Annual usage statement on
//                            request. seat-limited only.
//   --provenance-marks       Section 1C. Any scope.
//   --require-acceptance     Section 1D. Any scope.
//
// This script fills in the placeholders, picks one Operational Scope and
// includes or leaves out each optional provision — it does not otherwise
// alter the license text. See Section 2C.
//
// Piped from curl — pass every flag, since stdin is the script itself in
// this mode and interactive prompts have nothing to read:
//   curl -s https://raw.githubusercontent.com/estejosh/UFL-Usufruct-License/main/generate.js \
//     | node - -y 2026 -c "Jane Doe" -p "MyProject" -s unconditional > LICENSE
//
// Tracks UFL 2.3. See CHANGELOG.md for revisions. The 2.2 generator is
// kept unchanged at versions/2.2/generate.js.

'use strict';

const fs = require('fs');

const TEMPLATE = [
  'The Usufruct License (UFL) — Version 2.3',
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
  '[OPTIONAL SECTIONS]## 2. Reserved Rights',
  '',
  'The following rights are reserved to the Licensor and are NOT granted by',
  'Section 1. They require a separate written license from the Licensor,',
  'except as Section 2A permits:',
  '',
  '  (a) Distributing the Software, or any modified version, fork, or',
  '      substantially similar reimplementation of it, to any third party,',
  '      in source or compiled form.',
  "  (b) Incorporating the Software's source code into another product or",
  '      service that is distributed, sold, or otherwise made available to',
  '      third parties.',
  "  (c) Using the Licensor's name, marks, or claims of compatibility",
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
  "distributed product, and using the Licensor's name or marks to claim",
  'compatibility, still require a separate license regardless of',
  'attribution.',
  '',
  '## 2B. Reproducing This License Text',
  '',
  'The text of this license — this document itself, independent of any',
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
  'to modify. A copy of this text is adopted as-is. The blanks a Licensor',
  'may fill in are the copyright year, the copyright holder, and the',
  'project name given near the top of this text, together with the',
  'statements this text invites a Licensor to make: the free threshold and',
  'the seat definition in the Operational Scope line, and the number of',
  'lookback years in Section 1B. The choices a Licensor may make are which',
  'single Operational Scope in Section 1A applies, and which, if any, of',
  'the optional provisions in Sections 1B (paragraphs (a), (b) and (c)),',
  '1C and 1D are included. Each fill and each choice is stated exactly as',
  'the canonical text provides for it. A provision that is left out is',
  'left out whole, and the sections and paragraphs that remain keep their',
  'numbers and letters. Beyond those fills and choices, no wording in',
  'Sections 1 through 7 of this license, including this section, may be',
  'added to, removed, or altered in any copy that is presented, cited, or',
  'identified as "the Usufruct License," "UFL," or by any',
  '`LicenseRef-UFL-*` identifier. A project that needs different terms is',
  'free to write its own license, including one derived from this text',
  'under its own name — it is not free to alter this text and continue to',
  'call the result UFL.',
  '',
  'Anyone may propose a change for a future version at the canonical',
  'source named in Section 7. An adopted proposal becomes a new official',
  'version, never a retroactive edit: once a version of this license is',
  'published, its text is not changed, and a project that wants a later',
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
  '[SECTION 7 TAIL]',
  '',
  '---',
  'SPDX identifier: UFL is not on the official SPDX license list. Per SPDX',
  'convention for licenses outside that list, use `LicenseRef-UFL-2.3` —',
  'not a bare `UFL-2.3`, which would misrepresent it as SPDX-registered.',
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

function buildScope(scopeKey, threshold, seatDefinition) {
  if (scopeKey === 'seat-limited') {
    let line = 'Seat-Limited — ' + threshold + ' free in production';
    if (seatDefinition) line += ', where a seat is ' + seatDefinition;
    return {
      line: line,
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

// Optional provisions. Each is included only when its flag is passed.
function seatDefinitionText() {
  return [
    '  (a) Seat definition. The Licensor defines a seat in the Operational',
    '      Scope line above, and that definition decides how seats are',
    '      counted. A definition may count the people who hold roles the',
    "      Licensor names at the licensee's organization. If it does, each",
    '      such person is a seat whether or not that person runs the',
    '      Software.'
  ];
}

function useBeyondThresholdText(years) {
  return [
    '  (b) Use beyond the threshold. Production use beyond the free',
    '      threshold requires a paid, separate written license from the',
    '      Licensor, as Section 1A states. A licensee that makes production',
    '      use beyond the threshold without that license owes the Licensor,',
    '      for each period of that use, the price the Licensor had published',
    '      for that period for a license covering that use, and no more than',
    '      that price for the use itself. The Licensor may claim this only',
    '      for periods that began within the ' + years + '-year period',
    '      ending on the date of its written request for payment. Paying the',
    '      amount owed for a period licenses the use in that period.'
  ];
}

function usageStatementText() {
  return [
    "  (c) Usage statement. On the Licensor's written request, made no more",
    '      than once in any twelve months, a licensee whose production use',
    '      is above the free threshold provides a written statement of the',
    '      number of seats and the period of use, within a reasonable time.',
    '      The Licensor may not require the statement to include any data',
    '      the Software processed, or anything contained in that data.'
  ];
}

const PROVENANCE_MARKS_TEXT = [
  '## 1C. Provenance Marks',
  '',
  'The Software places technical marks in the outputs it produces. A mark',
  'shows that an output came from the Software and the license state of',
  'the copy that produced it, licensed or evaluation. A mark identifies no',
  'person or organization, and does not change the substantive content of',
  'an output. Removing, altering, or forging a mark is not permitted.'
];

const ACCEPTANCE_TEXT = [
  '## 1D. Acceptance',
  '',
  'The Software may require an affirmative act accepting this license',
  'before first use. Whether or not it does, use of the Software',
  'constitutes acceptance of this license.'
];

// "Section 1A" / "Sections 1A and 1B" / "Sections 1A, 1B and 1D"
function listRefs(refs) {
  if (refs.length === 1) return 'Section ' + refs[0];
  return 'Sections ' + refs.slice(0, -1).join(', ') + ' and ' + refs[refs.length - 1];
}

// Greedy word wrap to 72 columns.
function wrap(text) {
  const out = [];
  let line = '';
  text.split(/ +/).forEach(function (word) {
    if (line === '') line = word;
    else if (line.length + 1 + word.length <= 72) line += ' ' + word;
    else { out.push(line); line = word; }
  });
  if (line !== '') out.push(line);
  return out;
}

function buildOptional(args) {
  const refs = ['1A'];
  const blocks = [];

  const paras = [];
  if (args.seatDefinition) paras.push(seatDefinitionText());
  if (args.lookbackYears) paras.push(useBeyondThresholdText(args.lookbackYears));
  if (args.usageStatement) paras.push(usageStatementText());
  if (paras.length) {
    const lines = [
      '## 1B. Seat-Limited Terms',
      '',
      'This section applies only if the Operational Scope is Seat-Limited.',
      ''
    ];
    paras.forEach(function (p) { p.forEach(function (l) { lines.push(l); }); });
    blocks.push(lines.join('\n'));
    refs.push('1B');
  }
  if (args.provenanceMarks) { blocks.push(PROVENANCE_MARKS_TEXT.join('\n')); refs.push('1C'); }
  if (args.requireAcceptance) { blocks.push(ACCEPTANCE_TEXT.join('\n')); refs.push('1D'); }

  return {
    sections: blocks.map(function (b) { return b + '\n\n'; }).join(''),
    s7Tail: wrap('an additional condition on using the Software beyond ' + listRefs(refs) + '.').join('\n')
  };
}

function parseArgs(argv) {
  const out = {
    year: null, holder: null, project: null, scope: 'unconditional', threshold: null, out: null,
    seatDefinition: null, lookbackYears: null, usageStatement: false, provenanceMarks: false, requireAcceptance: false
  };
  function value(i, name) {
    if (i + 1 >= argv.length) {
      process.stderr.write('Missing value for ' + name + '\n');
      process.exit(1);
    }
    return argv[i + 1];
  }
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '-y') { out.year = value(i, a); i++; }
    else if (a === '-c') { out.holder = value(i, a); i++; }
    else if (a === '-p') { out.project = value(i, a); i++; }
    else if (a === '-s') { out.scope = value(i, a); i++; }
    else if (a === '-t') { out.threshold = value(i, a); i++; }
    else if (a === '-o') { out.out = value(i, a); i++; }
    else if (a === '--seat-definition') { out.seatDefinition = value(i, a); i++; }
    else if (a.indexOf('--seat-definition=') === 0) { out.seatDefinition = a.slice('--seat-definition='.length); }
    else if (a === '--lookback-years') { out.lookbackYears = value(i, a); i++; }
    else if (a.indexOf('--lookback-years=') === 0) { out.lookbackYears = a.slice('--lookback-years='.length); }
    else if (a === '--usage-statement') { out.usageStatement = true; }
    else if (a === '--provenance-marks') { out.provenanceMarks = true; }
    else if (a === '--require-acceptance') { out.requireAcceptance = true; }
    else if (a === '-h' || a === '--help') {
      process.stderr.write(
        'Usage: generate.js [-y YEAR] [-c "COPYRIGHT HOLDER"] [-p "PROJECT NAME"] [-s SCOPE] [-t THRESHOLD] [-o OUTPUT_PATH] [--seat-definition TEXT] [--lookback-years N] [--usage-statement] [--provenance-marks] [--require-acceptance]\n' +
        'SCOPE: unconditional | no-competing-service | no-third-party-hosting | noncommercial | seat-limited\n' +
        '--seat-definition, --lookback-years and --usage-statement apply only to SCOPE seat-limited.\n'
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

function fail(message) {
  process.stderr.write(message + '\n');
  process.exit(1);
}

// Placeholders first, then the scope, optional sections and Section 7
// tail, so a fill that happens to contain a bracketed token is left as
// typed.
function fill(template, year, holder, project, scope, optional) {
  const spdx = scope.suffix;
  const lines = template
    .split('[YEAR]').join(year)
    .split('[COPYRIGHT HOLDER]').join(holder)
    .split('[PROJECT NAME]').join(project)
    .split('LicenseRef-UFL-2.3`').join('LicenseRef-UFL-2.3' + spdx + '`')
    .split('`UFL-2.3`').join('`UFL-2.3' + spdx + '`')
    .split('\n');
  return lines.map(function (l) {
    if (l === 'Operational Scope: [OPERATIONAL SCOPE]') return 'Operational Scope: ' + scope.line;
    if (l === '[OPERATIONAL SCOPE BODY]') return scope.body.join('\n');
    if (l === '[SECTION 7 TAIL]') return optional.s7Tail;
    if (l.indexOf('[OPTIONAL SECTIONS]') === 0) return optional.sections + l.slice('[OPTIONAL SECTIONS]'.length);
    return l;
  }).join('\n');
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

  if (args.scope !== 'seat-limited' && (args.seatDefinition || args.lookbackYears || args.usageStatement)) {
    fail('--seat-definition, --lookback-years and --usage-statement apply only to SCOPE seat-limited.');
  }

  // A whole number of years, or a bracketed placeholder (used only to
  // render the reference text in LICENSE.txt).
  if (args.lookbackYears && !/^\[.*\]$/.test(args.lookbackYears) && !/^[1-9][0-9]?$/.test(args.lookbackYears)) {
    fail('--lookback-years must be a whole number from 1 to 99.');
  }

  let threshold = args.threshold;
  if (args.scope === 'seat-limited' && !threshold) {
    threshold = prompt('Free production threshold (e.g. "2 seats, 2 computers, 2 mobile devices"): ');
  }

  const scope = buildScope(args.scope, threshold, args.seatDefinition);
  const filled = fill(TEMPLATE, year, holder, project, scope, buildOptional(args));

  if (args.out) {
    fs.writeFileSync(args.out, filled);
  } else {
    process.stdout.write(filled);
  }
}

main();
