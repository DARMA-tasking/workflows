#!/usr/bin/env sh

# Basic universal setup script

WF_TMP_DIR=${WF_TMP_DIR:-"/opt/workflows"}

echo "------------- Setup --------------"

OS=
OS_VERSION=
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

# Save setup environment to ~/.setuprc (used by packages.sh dep for example)
echo "-- Set up variables (WF_SETUP_ID, OS_NAME, OS_VERSION) > ~/.setuprc"
{
    echo "export WF_SETUP_ID=\"$WF_SETUP_ID\""
    echo "export OS_NAME=\"$OS_NAME\""
    echo "export OS_VERSION=\"$OS_VERSION\""
} >> ~/.setuprc

### UPDATE PACKAGE LIST AND INSTALL START-UP PACKAGES: git, wget, bash.
echo "-- Installing Core packages ($OS_NAME)..."
if [ "$OS_NAME" = "Ubuntu" ]
then
    apt-get update -y -q
    apt-get install -y -q --no-install-recommends ca-certificates wget git python3 python3-yaml
elif [ "$OS_NAME" = "Alpine Linux" ]
then
    apk update
    apk add --no-cache wget git bash python3 py3-yaml
elif [ "$OS_NAME" = "macOS" ]
then
    brew update
else
    echo "Error. Please implement the pre-setup instructions for OS=$OS_NAME"
    exit 1
fi
