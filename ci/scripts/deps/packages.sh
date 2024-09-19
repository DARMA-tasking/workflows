#!/usr/bin/env bash

# Set up packages through the package manager

DEPS_DIR="$(dirname -- "$(realpath -- "$0")")"
PACKAGES="${1:-""}"
INSTALL_DEFAULT_PACKAGES=${2:-"1"}

echo "Set up dependencies..."
if [[ $(uname -a) == *"Darwin"* ]]; then
    bash $DEPS_DIR/packages-macos.sh "$PACKAGES" $INSTALL_DEFAULT_PACKAGES
    exit 0
elif [[ $(uname -a) == *"Linux"* ]]; then
    if [[ -f "/etc/lsb-release" ]]
    then
        . /etc/lsb-release
        if [[ $DISTRIB_ID == "Ubuntu" ]]
        then
            bash $DEPS_DIR/packages-ubuntu.sh "$PACKAGES"
            exit 0
        fi
    else
        echo "Distribution info not found !"
    fi
fi 

echo "Common dependencies script not implemented yet for current host"
exit 1
