#!/usr/bin/env bash

PACKAGES=$@

echo "PACKAGES=\"${PACKAGES}\""

brew install -y -q && \
    $PACKAGES
