#!/bin/bash

# List the repositories in the DARMA-tasking organization - in JSON format -
# that need to be checked

ORG=DARMA-tasking
EXCLUDE='[
    "DARMA-tasking.github.io",
    "find-unsigned-commits",
    "check-commit-format",
    "find-trailing-whitespace",
    "check-pr-fixes-issue",
    "vt-sample-project",
    "parallel-for-transformer",
    "detector",
    "workflows"
]'
JQ="$EXCLUDE as \$blacklist | .[] | select(.isFork | not) | select(.name as \$in | \$blacklist | index(\$in) | not)"
gh repo list $ORG --json name,defaultBranchRef,isFork --jq "$JQ" | jq -s 'sort_by(.name)'
