#!/bin/bash

CURRENT_DIR="$(dirname -- "$(realpath -- "$0")")" # Current directory
PARENT_DIR="$(dirname "$CURRENT_DIR")"

# Clean
rm -rf $CURRENT_DIR/repositories.json

echo "> Listing repositories"
gh repo list DARMA-tasking --json name --json defaultBranchRef >> $CURRENT_DIR/repositories.json

python $CURRENT_DIR/check_workflow_usage.py

# DARMA_REPOSITORIES=$(gh repo list DARMA-tasking --json name --jq '.[].name')
# DARMA_REPOSITORIES=(${DARMA_REPOSITORIES//\\n/ })
# readarray -td '' DARMA_REPOSITORIES < <(printf '%s\0' "${DARMA_REPOSITORIES[@]}" | sort -z)

# for e in "${DARMA_REPOSITORIES[@]}"; do
#     printf "%s\n" "${e}"
    
#     echo "Listing active workflows for $e"
#     gh workflow list --repo DARMA-Tasking/$e
# done

