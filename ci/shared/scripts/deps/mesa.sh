#!/usr/bin/env bash

# This script installs Mesa libraries and utilities

set -exo pipefail

# FIX MESA driver (Ubuntu 24.04).
# Error: MESA: error: ZINK: vkCreateInstance failed (VK_ERROR_INCOMPATIBLE_DRIVER)
# This should go to `extra_packages` section once Ubuntu 24.04 issue is fixed.
if [ ! -f "/etc/os-release" ]; then
    echo "This script is only available for Ubuntu Linux."
    exit 0
fi

OS=$(cat /etc/os-release | grep -E "^NAME=*" | cut -d = -f 2 | tr -d '"')
OS_VERSION=$(cat /etc/os-release | grep -E "^VERSION_ID=*" | cut -d = -f 2 | tr -d '"')

if [ "$OS" == "Ubuntu" ]; then
    if [ "$OS_VERSION=" == "24.04" ]; then
        echo "FIX: Using latest MESA drivers (dev) for Ubuntu 24.04 to fix MESA errors !"
        add-apt-repository ppa:oibaf/graphics-drivers -y
        apt-get update
    fi

    apt-get update -y -q
    apt-get install -y -q --no-install-recommends \
        libgl1-mesa-dev \
        libglu1-mesa-dev \
        mesa-common-dev \
        libosmesa6-dev \
        mesa-utils
    apt-get clean -y -q
    rm -rf /var/lib/apt/lists/*
else
    echo "This script is only available for Ubuntu Linux."
fi
