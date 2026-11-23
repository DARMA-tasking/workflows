#!/bin/bash

# This script builds VTK (required by vt-tv)

set -exo pipefail

if test $# -lt 1
then
    echo "usage: ./$0 <version> [<src-dir> <build-dir>]"
    exit 1
fi

VTK_VERSION=$1
VTK_SRC_DIR=${2:-"/opt/vtk/src"}
VTK_BUILD_DIR=${3:-${VTK_DIR:-"/opt/vtk/build"}}

# VTK 9.4+ exposes JSON in public headers. Use the system package so vt-tv
# and VTK share nlohmann_json rather than VTK's private, renamed copy.
if [ "$(uname)" = "Darwin" ]; then
    brew install nlohmann-json
else
    apt-get update -y -q
    apt-get install -y -q --no-install-recommends nlohmann-json3-dev
    apt-get clean -y -q
    rm -rf /var/lib/apt/lists/*
fi

echo "Installing VTK $VTK_VERSION..."
git clone --recursive --branch v${VTK_VERSION} https://gitlab.kitware.com/vtk/vtk.git ${VTK_SRC_DIR}

mkdir -p $VTK_BUILD_DIR
pushd $VTK_BUILD_DIR

cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=OFF \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DVTK_MODULE_USE_EXTERNAL_VTK_nlohmannjson:BOOL=ON \
  -S "$VTK_SRC_DIR" -B "$VTK_BUILD_DIR"
cmake --build "$VTK_BUILD_DIR" -j$(nproc)
echo "VTK build success"
popd

echo "VTK $VTK_VERSION has been installed successfully."
