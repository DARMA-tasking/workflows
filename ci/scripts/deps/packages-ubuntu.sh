#!/usr/bin/env bash

PACKAGES=${1:-''}
PACKAGES=${PACKAGES//,/ }
INSTALL_DEFAULT_PACKAGES=${2:-"1"}
DEFAULT_PACKAGES=$(
echo "ca-certificates \
less \
curl \
git \
wget \
zlib1g \
zlib1g-dev \
ninja-build \
valgrind \
make-guile \
libomp5 \
libunwind-dev \
ccache")

if [[ $INSTALL_DEFAULT_PACKAGES == "0" ]]
then
    $DEFAULT_PACKAGES=""
else
    echo "DEFAULT_PACKAGES=${DEFAULT_PACKAGES}"
fi

echo "PACKAGES=${PACKAGES}"

apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
    $DEFAULT_PACKAGES \
    $PACKAGES && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
