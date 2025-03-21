#!/usr/bin/env sh

# Basic universal setup script

echo "------------- Setup --------------"

UNAME=$(uname)
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
echo "PATH=$PATH"
echo "CPATH=$CPATH"
echo "LIBRARY_PATH=$LIBRARY_PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "----------------------------------"

### UPDATE PACKAGE LIST AND INSTALL CORE DEPENDENCIES
echo "-- Installing base packages ($OS_NAME)..."

set -eux

BASE_PACKAGES="$@"
if [ "$OS_NAME" = "Ubuntu" ]
then
    apt-get update -y -q
    apt-get install -y -q --no-install-recommends \
        $BASE_PACKAGES
    apt-get clean -y -q
    rm -rf /var/lib/apt/lists/*
elif [ "$OS_NAME" = "Alpine Linux" ]
then
    apk update
    apk add --no-cache $BASE_PACKAGES
elif [ "$OS_NAME" = "macOS" ]
then
    brew update
else
    echo "Error. Please implement installation instructions for OS=$OS_NAME"
    exit 1
fi

echo "--"
echo "-- Base packages installed!"
echo "--"
