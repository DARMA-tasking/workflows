#!/usr/bin/env bash

echo "Installing dependencies..."

CURRENT_DIR="$(dirname -- "$(realpath -- "$0")")"

pushd $CURRENT_DIR

%INSTRUCTIONS%

popd