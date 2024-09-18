#!/bin/bash

CURRENT_DIR="$(dirname -- "$(realpath -- "$0")")" # Current directory
PARENT_DIR="$(dirname "$CURRENT_DIR")"
WORKING_DIR="$PARENT_DIR/output"
ORG=DARMA-tasking
REPOSITORY=$1
EXPECTED_WORKFLOWS=( \
find-unsigned-commits \
check-commit-format \
find-trailing-whitespace \
check-pr-fixes-issue \
action-git-diff-check \
)

# Clean
rm -rf $WORKING_DIR
mkdir -p $WORKING_DIR

# Initialize
N_ERRORS=0
TSSTART=$(date +%s)
echo "$ORG/$REPOSITORY > Cloning repository...";
git clone https://github.com/$ORG/$REPOSITORY $WORKING_DIR/$REPOSITORY >/dev/null 2>&1

# Ckeck workflows (files exist as expected)
for w in "${EXPECTED_WORKFLOWS[@]}"
do
    if [ ! -f "$WORKING_DIR/$REPOSITORY/.github/workflows/$w.yml" ]; then
        echo "[error] Missing workflow file '$w.yml' at $WORKING_DIR/$REPOSITORY/.github/workflows/$w.yml"
        ((N_ERRORS++))
    else
        echo "[ok] workflow file '$w.yml' OK"
    fi
done

# Finalize
TSEND=$(date +%s)
TSDURATION=$(( $TSEND - $TSSTART ))
if [[ $N_ERRORS -gt 0 ]]
then
    echo "$WORKING_DIR/$REPOSITORY has $N_ERRORS errors."
else
    echo "[success] repository checks OK."
fi
echo "$WORKING_DIR/$REPOSITORY has been processed in $TSDURATION seconds."
echo "--------------------------------------------------";

if [[ $N_ERRORS -gt 0 ]]
then
    exit 1
fi
