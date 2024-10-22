#!/usr/bin/env sh

#
# macos-14-arm64, clang-14, mpich - Installation
# Note: requires
# - `git` and `wget` installed.
# - run as root

#
# IMPORTANT: This file has been generated by a script. Please do not edit !
#

SCRIPTS_INSTALL_DIR=/opt/scripts/ci
# TODO: change 2-implement-common-docker-containers to master once scripts when PR is ready
SCRIPTS_DEPS_URL="https://raw.githubusercontent.com/DARMA-tasking/workflows/refs/heads/2-implement-common-docker-containers/ci/shared/scripts/deps"

echo "------------- Setup --------------"

OS=
OS_VERSION=
UNAME=$(uname)
DOCKER_RUN=${DOCKER_RUN:-"0"}
if [ "$UNAME" = "Darwin" ]
then
    OS_NAME=$(sw_vers -productName)
    OS_VERSION=$(sw_vers -productVersion)
elif [ "$UNAME" = "Linux" ]
then
    OS_NAME=$(cat /etc/os-release | grep -E "^NAME=*" | cut -d = -f 2 | tr -d '"')
    OS_VERSION=$(cat /etc/os-release | grep -E "^VERSION_ID=*" | cut -d = -f 2 | tr -d '"')
fi

echo "Operating system: $OS_NAME / Version: $OS_VERSION"
echo "DOCKER_RUN=$DOCKER_RUN"
echo "CI=$CI"
echo "PATH=$PATH"
echo "CPATH=$CPATH"
echo "LIBRARY_PATH=$LIBRARY_PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "----------------------------------"

# Save setup environment to ~/.setuprc (used by packages.sh dep for example)
echo "-- Set up variables (SETUP_ID, OS_NAME, OS_VERSION, DOCKER_RUN) > ~/.setuprc"
echo "export SETUP_ID=\"$SETUP_ID\"" >> ~/.setuprc
echo "export DOCKER_RUN=\"$DOCKER_RUN\"" >> ~/.setuprc
echo "export OS_NAME=\"$OS_NAME\"" >> ~/.setuprc
echo "export OS_VERSION=\"$OS_VERSION\"" >> ~/.setuprc
echo "export CI=\"$CI\"" >> ~/.setuprc

### UPDATE PACKAGE LIST AND INSTALL START-UP PACKAGES: git, wget, bash.
echo "-- Installing Core packages ($OS_NAME)..."
if [ "$OS_NAME" = "Ubuntu" ]
then
    apt-get update -y -q
    apt-get install -y -q --no-install-recommends ca-certificates wget git
elif [ "$OS_NAME" = "Alpine Linux" ]
then
    apk update
    apk add --no-cache wget git bash
elif [ "$OS_NAME" = "macOS" ]
then
    brew update
else
    echo "Error. Please implement the pre-setup instructions for OS=$OS_NAME"
    exit 1
fi

echo "--"
echo "-- Core packages installed !"
echo "--"

### SETUP DEPENDENCIES

echo "--"
echo "-- Installing dependencies..."
echo "--"

mkdir -p $SCRIPTS_INSTALL_DIR
mkdir -p $SCRIPTS_INSTALL_DIR/deps
# 1. Download dependency installation script
cd $SCRIPTS_INSTALL_DIR/deps
wget $SCRIPTS_DEPS_URL/packages.sh
wget $SCRIPTS_DEPS_URL/mpich.sh
# 2. Install dependency
chmod u+x *.sh
ls -l
./packages.sh "ccache" "coreutils" "ninja"
CC="clang" CXX="clang++" ./mpich.sh "4.0.2" "-j4"

# Remove install scripts
rm -rf $SCRIPTS_INSTALL_DIR
if [ "$DOCKER_RUN" = "1" ]; then
    rm -rf /var/lib/apt/lists/*
fi

echo "--"
echo "-- Dependencies installed !"
echo "--"

### CLEAN-UP
if [ "$OS_NAME" = "Ubuntu" ]
then
    rm -rf /var/lib/apt/lists/*
elif [ "$OS_NAME" = "Alpine Linux" ]
then
    :
elif [ "$OS_NAME" = "macOS" ]
then
   :
else
    echo "No cleanup instructions defined for OS=$OS."
fi

echo "---------- Setup OK ! ------------"
echo "--"
echo "Operating system: $OS_NAME / Version: $OS_VERSION"
echo "CI: $CI / DOCKER_RUN: $DOCKER_RUN"
echo "--"
echo "Setup id: $SETUP_ID"
echo "--"
echo "Environment:"
echo "  CC=$CC"
echo "  CXX=$CXX"
echo "  CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"
echo "  CMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD"
echo "  FC=$FC"
echo "  PATH=$PATH"
echo "--"
echo "-------- Ready to test ! ---------"
echo "--"