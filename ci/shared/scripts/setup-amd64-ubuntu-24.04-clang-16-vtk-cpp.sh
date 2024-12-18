#!/usr/bin/env sh

#
# clang-16, ubuntu, mpich, vtk - Installation
# Note: requires
# - `git` and `wget` installed.
# - run as root

#
# IMPORTANT: This file has been generated by a script. Please do not edit !
#

WF_TMP_DIR=${WF_TMP_DIR:-"/opt/workflows/tmp"}

echo "------------- Setup --------------"

OS=
OS_VERSION=
UNAME=$(uname)
WF_DOCKER=${WF_DOCKER:-"0"}
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
echo "WF_DOCKER=$WF_DOCKER"
echo "PATH=$PATH"
echo "CPATH=$CPATH"
echo "LIBRARY_PATH=$LIBRARY_PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "----------------------------------"

# Save setup environment to ~/.setuprc (used by packages.sh dep for example)
echo "-- Set up variables (WF_SETUP_ID, WF_DOCKER, OS_NAME, OS_VERSION) > ~/.setuprc"
{
    echo "export WF_SETUP_ID=\"$WF_SETUP_ID\""
    echo "export WF_DOCKER=\"$WF_DOCKER\""
    echo "export OS_NAME=\"$OS_NAME\""
    echo "export OS_VERSION=\"$OS_VERSION\""
} >> ~/.setuprc

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

set -e

### SETUP DEPENDENCIES

echo "--"
echo "-- Installing dependencies..."
echo "--"

if [ $WF_DOCKER == "1" ]; then
    WF_DEPS_URL="https://raw.githubusercontent.com/DARMA-tasking/workflows/refs/heads/2-implement-common-docker-containers/ci/shared/scripts/deps"
    # if this is run directly from a runner from an external project
    # trigger deps download from the workflows repo.
    mkdir -p $WF_TMP_DIR
    mkdir -p $WF_TMP_DIR/deps
    # 1. Download dependency installation script
    cd $WF_TMP_DIR/deps
    wget $WF_DEPS_URL/packages.sh
    wget $WF_DEPS_URL/cmake.sh
    wget $WF_DEPS_URL/libunwind.sh
    wget $WF_DEPS_URL/mpich.sh
    wget $WF_DEPS_URL/mesa.sh
    wget $WF_DEPS_URL/vtk.sh
else
    cd $WF_TMP_DIR/deps
fi

chmod u+x *.sh
ls -l
./packages.sh "curl" "jq" "less" "libomp5" "libunwind-dev" "make-guile" "ninja-build" "valgrind" "zlib1g" "zlib1g-dev" "ccache" "python3" "clang-16" "llvm-16"
./cmake.sh "3.23.4"
./libunwind.sh "1.6.2"
./mpich.sh "4.0.2" "-j4"
./mesa.sh
./vtk.sh "9.3.1"

# Remove install scripts
rm -rf $WF_SCRIPTS_DIR

if [ "$WF_DOCKER" = "1" ]; then
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
echo "--"
echo "Setup id: $WF_SETUP_ID"
echo "Docker: $WF_DOCKER"
echo "--"
echo "Environment:"
echo "  CC=$CC"
echo "  CXX=$CXX"
echo "  FC=$FC"
echo "  PATH=$PATH"
echo "--"
echo "-------- Ready to test ! ---------"
echo "--"
