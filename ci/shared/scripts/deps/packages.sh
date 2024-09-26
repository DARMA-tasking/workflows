#!/usr/bin/env bash

# Set up packages through the package manager

DEPS_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=$@

echo "Install system packages..."
if [[ $(uname -a) == *"Darwin"* ]]; then
    brew update && \
    brew install \
        $PACKAGES
    exit 0
elif [[ $(uname -a) == *"Linux"* ]]; then
    OS=$(cat /etc/os-release | grep -E "^NAME=*" | cut -d = -f 2 | tr -d '"')
    if [[ $OS == "Ubuntu" ]]
    then
        . /etc/lsb-release
        if [[ $DISTRIB_ID == "Ubuntu" ]]
        then
            apt-get update -y -q && \
            apt-get install -y -q --no-install-recommends \
                $PACKAGES && \
                apt-get clean
            exit 0
        fi
    else
        echo "Not implemented for OS $OS !"
        exit 1
    fi
fi

echo "Not implemented for $(uname -a) !"
exit 1
