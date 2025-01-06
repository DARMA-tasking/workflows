#!/bin/bash

# Check that a repository is compliant:
# - required file exists
# - file uses the correct workflow

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

# Ckeck workflows (files exist as expected and contain correct workflow)
for w in "${EXPECTED_WORKFLOWS[@]}"
do
    WORKFLOW_FILE="$WORKING_DIR/$REPOSITORY/.github/workflows/$w.yml"
    if [ ! -f "$WORKFLOW_FILE" ]; then
        echo "[error] Missing workflow file '$w.yml' at $WORKFLOW_FILE"
        ((N_ERRORS++))
    else
        # Check that the correct workflow is used
        if ! grep -q "uses: DARMA-tasking/$w" "$WORKFLOW_FILE"; then
            echo "[error] Workflow file '$w.yml' does not contain 'uses: DARMA-tasking/$w'"
            ((N_ERRORS++))
        else
            echo "[ok] workflow file '$w.yml is correct"
        fi
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