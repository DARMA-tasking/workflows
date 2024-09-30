#!/usr/bin/env sh

#
# macos-14-arm64, clang-14 - Installation
# Note: requires
# - `git` and `wget` installed.
# - run as root

#
# IMPORTANT: This file has been generated by a script. Please do not edit !
#

SCRIPTS_INSTALL_DIR=/opt/scripts/ci
# TODO: change 2-implement-common-docker-containers to master once scripts when PR is ready
SCRIPTS_DEPS_URL="https://raw.githubusercontent.com/DARMA-tasking/workflows/refs/heads/2-implement-common-docker-containers/ci/shared/scripts/deps"

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

# Save setup environment
echo "export OS_NAME=\"$OS_NAME\"" >> ~/.setuprc
echo "export OS_VERSION=\"$OS_VERSION\"" >> ~/.setuprc
echo "export SETUP_ID=\"$SETUP_ID\"" >> ~/.setuprc
echo "export DOCKER_RUN=\"$DOCKER_RUN\"" >> ~/.setuprc

echo "/////////////////////////////////////////////////"
echo "Setup script"
echo "/////////////////////////////////////////////////"
echo "Operating system: $OS_NAME / Version: $OS_VERSION"
echo "Setup configuration:"
echo "> Setup Id (SETUP_ID): $SETUP_ID"
echo "> C Compiler (CC): $CC"
echo "> C++ Compiler (CXX): $CXX"
echo "> Fortran Compiler (FC): $FC"
echo "> Build type (CMAKE_BUILD_TYPE): $CMAKE_BUILD_TYPE"
echo "> C++ Standard (CMAKE_CXX_STANDARD): $CMAKE_CXX_STANDARD"

echo "/////////////////////////////////////////////////"

### UPDATE PACKAGE LIST AND INSTALL START-UP PACKAGES: git, wget, bash.
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

### SETUP DEPENDENCIES
mkdir -p $SCRIPTS_INSTALL_DIR
mkdir -p $SCRIPTS_INSTALL_DIR/deps
# 1. Download dependency installation script
cd $SCRIPTS_INSTALL_DIR/deps
wget $SCRIPTS_DEPS_URL/packages.sh
# 2. Install dependency
chmod u+x *.sh
ls -l
./packages.sh "ccache" "coreutils"

# Remove install scripts
rm -rf $SCRIPTS_INSTALL_DIR
if [ "$DOCKER_RUN" = "1" ]; then
    rm -rf /var/lib/apt/lists/*
fi

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

if [ -e "opt/nvcc_wrapper/bin/nvcc_wrapper" ] 
then
    export CXX=nvcc_wrapper
fi
