#!/usr/bin/env bash

#
# %ENVIRONMENT_LABEL% - Installation
# Note: requires
# - `git` and `wget` installed.
# - run as root

#
# IMPORTANT: This file has been generated by a script. Please do not edit !
#

SCRIPTS_REPO=DARMA-tasking/workflows
SCRIPTS_REPO_BRANCH=2-implement-common-docker-containers
SCRIPTS_DEP_REGEX="ci/shared/scripts/deps/.*\.sh"
SCRIPTS_INSTALL_DIR=/opt/scripts/ci

mkdir -p $SCRIPTS_INSTALL_DIR

# List scripts in `ci/shared/scripts/deps` from the scripts repository
mkdir -p ~/tmp
pushd ~/tmp
git clone -b 2-implement-common-docker-containers --no-checkout --depth 1 https://github.com/$SCRIPTS_REPO workflows
ls -l
pushd workflows
arr=($(git ls-tree -r --name-only refs/heads/$SCRIPTS_REPO_BRANCH | grep -E "$SCRIPTS_DEP_REGEX"))
popd # ~/tmp/workflows
popd # ~/tmp
rm -rf ~/tmp

# Retrieve scripts from remote & run setup instructions
mkdir -p $SCRIPTS_INSTALL_DIR/deps
pushd $SCRIPTS_INSTALL_DIR/deps
for script_name in ${arr[@]}
do
    wget https://raw.githubusercontent.com/$SCRIPTS_REPO/refs/heads/$SCRIPTS_REPO_BRANCH/$script_name
done
# Install dependencies
chmod u+x *.sh
ls -l
%INSTRUCTIONS%
popd # $SCRIPTS_INSTALL_DIR/deps

echo "Cleaning..."
rm -rf $SCRIPTS_INSTALL_DIR
