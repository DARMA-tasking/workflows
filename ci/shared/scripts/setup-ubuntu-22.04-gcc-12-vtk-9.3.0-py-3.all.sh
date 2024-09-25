#!/usr/bin/env bash

#
# vt-tv, gcc-12, ubuntu, vtk 9.3.0, py3[8-12] - Installation
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
wget $SCRIPTS_DEPS_URL/mesa.sh
wget $SCRIPTS_DEPS_URL/conda.sh
wget $SCRIPTS_DEPS_URL/conda-python-env.sh
wget $SCRIPTS_DEPS_URL/cmake.sh
wget $SCRIPTS_DEPS_URL/vtk.sh

# > Run install instructions
chmod u+x *.sh
ls -l
./packages.sh "ca-certificates" "curl" "git" "jq" "less" "libomp5" "libunwind-dev make-guile" "ninja-build" "valgrind" "wget" "zlib1g" "zlib1g-dev" "ccache" "python3" "gcc-12" "g++-12"
./mesa.sh 
./conda.sh 
./conda-python-env.sh "3.8" "nanobind yaml setuptools"
./conda-python-env.sh "3.9" "nanobind yaml setuptools"
./conda-python-env.sh "3.10" "nanobind yaml setuptools"
./conda-python-env.sh "3.11" "nanobind yaml setuptools"
./conda-python-env.sh "3.12" "nanobind yaml setuptools"
./cmake.sh "3.30.3"
./vtk.sh "9.3.0"

popd # $SCRIPTS_INSTALL_DIR/deps

echo "Cleaning..."
rm -rf $SCRIPTS_INSTALL_DIR