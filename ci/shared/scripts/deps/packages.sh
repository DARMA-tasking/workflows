#!/usr/bin/env bash

# Set up packages through the package manager

DEPS_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=$@

. ~/.setuprc

echo "Install system packages..."
if [ "$OS_NAME" == "Ubuntu" ]
then
    apt-get install -y -q --no-install-recommends \
            $PACKAGES && \
            apt-get clean
        exit 0
elif [ "$OS_NAME" == "Alpine Linux" ]
then
    apk update && apk add --no-cache \
        $PACKAGES
elif [ "$OS_NAME" == "macOS" ]
then
    brew install \
        $PACKAGES
    exit 0
else
    echo "Not implemented for OS `$OS_NAME` !"
    exit 1
fi