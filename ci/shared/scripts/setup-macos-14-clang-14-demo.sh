#!/usr/bin/env bash

#
# demo, macos-14, clang-14 - Installation
# Note: requires
# - `git` and `wget` installed.
# - run as root

#
# IMPORTANT: This file has been generated by a script. Please do not edit !
#

SCRIPTS_INSTALL_DIR=/opt/scripts/ci
# TODO: change 2-implement-common-docker-containers to master once scripts when PR is ready
SCRIPTS_DEPS_URL="https://raw.githubusercontent.com/DARMA-tasking/workflows/refs/heads/2-implement-common-docker-containers/ci/shared/scripts/deps"

mkdir -p $SCRIPTS_INSTALL_DIR

# Dependencies
mkdir -p $SCRIPTS_INSTALL_DIR/deps
# > Retrieve .sh scripts
pushd $SCRIPTS_INSTALL_DIR/deps
wget $SCRIPTS_DEPS_URL/packages.sh

# > Run install instructions
chmod u+x *.sh
ls -l
./packages.sh "coreutils"

popd # $SCRIPTS_INSTALL_DIR/deps

echo "Cleaning..."
rm -rf $SCRIPTS_INSTALL_DIR
