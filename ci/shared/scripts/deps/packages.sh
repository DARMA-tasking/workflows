#!/usr/bin/env bash

# Set up packages through the package manager

DEPS_DIR="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"

PACKAGES=$@

echo "Install system packages..."
if [[ $(uname -a) == *"Darwin"* ]]; then
    bash $DEPS_DIR/packages-macos.sh $PACKAGES
    exit 0
elif [[ $(uname -a) == *"Linux"* ]]; then
    if [[ -f "/etc/lsb-release" ]]
    then
        . /etc/lsb-release
        if [[ $DISTRIB_ID == "Ubuntu" ]]
        then
            bash $DEPS_DIR/packages-ubuntu.sh $PACKAGES
            exit 0
        fi
    else
        echo "Distribution info not found !"
    fi
fi 

echo "Common dependencies script not implemented yet for current host"
exit 1
