#!/bin/bash

CURRENT_DIR="$(dirname -- "$(realpath -- "$0")")" # Current directory
PARENT_DIR="$(dirname "$CURRENT_DIR")"
WORKING_DIR="$PARENT_DIR/output"
ORG=DARMA-tasking
# Clean
rm -rf $WORKING_DIR
mkdir -p $WORKING_DIR

DARMA_REPOSITORIES=$(gh repo list $ORG --json name --jq '.[].name')
DARMA_REPOSITORIES=(${DARMA_REPOSITORIES//\\n/ })
readarray -td '' DARMA_REPOSITORIES < <(printf '%s\0' "${DARMA_REPOSITORIES[@]}" | sort -z)

EXCLUDE_REPOS=(\
DARMA-tasking.github.io
)

CHECKS_REPOS=( \
find-unsigned-commits \
check-commit-format \
find-trailing-whitespace \
check-pr-fixes-issue \
)

EXPECTED_WORKFLOWS=( \
find-unsigned-commits \
check-commit-format \
find-trailing-whitespace \
check-pr-fixes-issue \
action-git-diff-check \
)

for e in "${DARMA_REPOSITORIES[@]}"
do
    printf "%s\n" "${e}"
    
    if [[ " ${CHECKS_REPOS[*]} " =~ [[:space:]]${e}[[:space:]] ]]; then
        echo "$ORG/$e > Ignoring (checks repository)";
        echo "--------------------------------------------------";
    elif [[ " ${EXCLUDE_REPOS[*]} " =~ [[:space:]]${e}[[:space:]] ]]; then
        echo "$ORG/$e > Ignoring (excluded)";
        echo "--------------------------------------------------";
    else
        TSSTART=$(date +%s)
        echo "$ORG/$e > Cloning repository...";
        git clone https://github.com/$ORG/$e $WORKING_DIR/$e >/dev/null 2>&1
        for w in "${EXPECTED_WORKFLOWS[@]}"
        do
            if [ ! -f "$WORKING_DIR/$e/.github/workflows/$w.yml" ]; then
                echo "[error] Missing workflow file '$w.yml' at $WORKING_DIR/$e/.github/workflows/$w.yml"
            else
                echo "[ok] workflow file '$w.yml' OK"
            fi
        done
        TSEND=$(date +%s)
        TSDURATION=$(( $TSEND - $TSSTART ))
        echo "$WORKING_DIR/$e has been processed in $TSDURATION seconds."
        echo "--------------------------------------------------";
    fi
done

