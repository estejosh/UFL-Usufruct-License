#!/bin/sh
# Gate a UFL project's branch on the CLA check and signed commits, and create
# the unprotected branch the CLA signatures are committed to.
#
# Needs a GitHub PAT in $GITHUB_PAT with, on the repository, Administration:
# write and Contents: write. It does not use any other GitHub login.
#
# Usage:  GITHUB_PAT=... sh setup.sh OWNER/REPO [BRANCH]
#         DRY_RUN=1 GITHUB_PAT=x sh setup.sh OWNER/REPO    # print the calls only
set -eu

REPO=${1:?usage: setup.sh OWNER/REPO [BRANCH]}
BRANCH=${2:-main}
: "${GITHUB_PAT:?set GITHUB_PAT}"
API=https://api.github.com/repos/$REPO

call() { # METHOD PATH [JSON BODY]
  if [ -n "${DRY_RUN:-}" ]; then echo "$1 $API$2 ${3:-}" >&2; return 0; fi
  curl -sS -f -X "$1" -H "Authorization: Bearer $GITHUB_PAT" \
    -H "Accept: application/vnd.github+json" "$API$2" ${3:+-d "$3"}
}

# 1. Signatures branch, from the tip of BRANCH (skipped if it already exists).
if [ -n "${DRY_RUN:-}" ]; then
  SHA=SHA_OF_$BRANCH
else
  SHA=$(call GET "/git/ref/heads/$BRANCH" | sed -n 's/.*"sha": *"\([0-9a-f]\{40\}\)".*/\1/p' | head -1)
fi
[ -n "$SHA" ] || { echo "could not read $BRANCH" >&2; exit 1; }
call POST /git/refs "{\"ref\":\"refs/heads/cla-signatures\",\"sha\":\"$SHA\"}" >/dev/null \
  || echo "cla-signatures already exists (or could not be created); continuing" >&2

# 2. Require a pull request and the CLAAssistant check on BRANCH.
call PUT "/branches/$BRANCH/protection" '{"required_status_checks":{"strict":false,"contexts":["CLAAssistant"]},"enforce_admins":false,"required_pull_request_reviews":{"required_approving_review_count":0},"restrictions":null}' >/dev/null

# 3. Require signed commits on BRANCH.
call POST "/branches/$BRANCH/protection/required_signatures" >/dev/null

echo "done: $REPO $BRANCH now requires a pull request, the CLAAssistant check, and signed commits."
