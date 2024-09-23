#!/usr/bin/env bash

PACKAGES=$@

echo "PACKAGES=\"${PACKAGES}\""

apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
    $PACKAGES && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
