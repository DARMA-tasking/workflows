#!/bin/bash

ORG=DARMA-tasking
EXCLUDE="[\"DARMA-tasking.github.io\",\"find-unsigned-commits\",\"check-commit-format\",\"find-trailing-whitespace\",\"check-pr-fixes-issue\",\"workflows\"]"
JQ="$EXCLUDE as \$blacklist | .[] | select( .name as \$in | \$blacklist | index(\$in) | not)"
gh repo list $ORG --json name,defaultBranchRef --jq "$JQ" | jq -s 'sort_by(.name)'
