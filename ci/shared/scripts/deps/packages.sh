#!/usr/bin/env bash

# Set up packages through the package manager

DEPS_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=$@

echo "Install system packages..."
if [[ $(uname -a) == *"Darwin"* ]]; then
    brew install -y -q && \
        $PACKAGES
    exit 0
elif [[ $(uname -a) == *"Linux"* ]]; then
    if [[ -f "/etc/lsb-release" ]]
    then
        . /etc/lsb-release
        if [[ $DISTRIB_ID == "Ubuntu" ]]
        then
            apt-get update -y -q && \
            apt-get install -y -q --no-install-recommends \
            $PACKAGES && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/*
            exit 0
        fi
    else
        echo "Distribution info not found !"
    fi
fi 

echo "Packages installation not supported ! Currently supported are Ubuntu/apt-get, Darwin/brew  "
exit 1
