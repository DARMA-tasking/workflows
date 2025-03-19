#!/usr/bin/env sh

#
# %ENVIRONMENT_LABEL% - Installation
# Note: requires
# - `git` and `wget` installed.
# - run as root

#
# IMPORTANT: This file has been generated by a script. Please do not edit !
#

WF_TMP_DIR=${WF_TMP_DIR:-"/opt/workflows"}

echo "------------- Setup --------------"

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

set -e

### INSTALL DEPENDENCIES
echo "--"
echo "-- Installing dependencies..."
echo "--"

cd $WF_TMP_DIR/shared/scripts/deps
chmod u+x *.sh
ls -l
%DEPS_INSTALL%

echo "--"
echo "-- Dependencies installed!"
echo "--"

echo "---------- Setup OK ! ------------"
echo "--"
echo "Operating system: $OS_NAME / Version: $OS_VERSION"
echo "--"
echo "Setup id: $WF_SETUP_ID"
echo "--"
echo "Environment:"
echo "  CC=$CC"
echo "  CXX=$CXX"
echo "  FC=$FC"
echo "  PATH=$PATH"
echo "--"
echo "-------- Ready to test ! ---------"
echo "--"
