#!/bin/bash

CURRENT_DIR="$(dirname -- "$(realpath -- "$0")")" # Current directory
PARENT_DIR="$(dirname "$CURRENT_DIR")"
WORKING_DIR="$PARENT_DIR/output"
ORG=DARMA-tasking

EXCLUDE='[
    "DARMA-tasking.github.io",
    "find-unsigned-commits",
    "check-commit-format",
    "find-trailing-whitespace",
    "check-pr-fixes-issue"
]'
JQ=$EXCLUDE' as $blacklist | .[] | select( .name as $in | $blacklist | index($in) | not)'
gh repo list DARMA-tasking --json name,defaultBranchRef --jq "$JQ" --jq 'sort_by(.name)' | jq
