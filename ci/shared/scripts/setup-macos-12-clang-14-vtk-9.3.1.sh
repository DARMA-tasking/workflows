#!/usr/bin/env bash

# This file has been generated by a script. Do not edit.

echo "Installing dependencies..."

CURRENT_DIR="$(dirname -- "$(realpath -- "$0")")"

pushd $CURRENT_DIR

./deps/packages.sh "ca-certificates" "less" "curl" "jq" "git" "wget" "zlib1g" "zlib1g-dev" "ninja-build" "valgrind" "make-guile" "libomp5" "libunwind-dev" "ccache" "clang-14" "clang-14++"
./deps/conda.sh 
./deps/vtk.sh "9.3.1"

popd