#!/usr/bin/env bash

PACKAGES=$@

echo "PACKAGES=\"${PACKAGES}\""

apt-get brew install -y -q && \
    $PACKAGES
