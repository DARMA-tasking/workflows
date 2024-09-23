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
VTK_INSTALL_DIR=${3:-VTK_DIR:-"/opt/vtk/build"}

echo "Installing VTK $VTK_VERSION..."
git clone --recursive --branch v${VTK_VERSION} https://gitlab.kitware.com/vtk/vtk.git ${VTK_SRC_DIR}

mkdir -p $VTK_INSTALL_DIR
pushd $VTK_INSTALL_DIR

cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=OFF \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -S "$VTK_SRC_DIR" -B "$VTK_INSTALL_DIR"
cmake --build "$VTK_INSTALL_DIR" -j$(nproc)

echo "VTK build success"
popd

echo "VTK $VTK_VERSION has been installed successfully."
