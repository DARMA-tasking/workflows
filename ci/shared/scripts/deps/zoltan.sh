#!/usr/bin/env bash

set -exo pipefail

if test $# -lt 1
then
    echo "usage: ./$0 <make_flags> <install-dir>"
    exit 1
fi

ZOLTAN_SRC_DIR="/opt/trilinos/src"
ZOLTAN_BUILD_DIR="/opt/trilinos/build"
ZOLTAN_MAKE_FLAGS=${1:-""}
ZOLTAN_INSTALL_DIR=${2:-ZOLTAN_INSTALL_DIR:-"/opt/trilinos/bin"}

if test -d Trilinos
then
    echo "Found Trilinos already"
else
    git clone https://github.com/trilinos/Trilinos.git --depth=1 $ZOLTAN_SRC_DIR
fi

mkdir -p ${ZOLTAN_SRC_DIR}
mkdir -p ${ZOLTAN_BUILD_DIR}
mkdir -p ${ZOLTAN_INSTALL_DIR}

cd ${ZOLTAN_BUILD_DIR}

cmake \
  -DCMAKE_INSTALL_PREFIX:FILEPATH=${ZOLTAN_INSTALL_DIR} \
  -DTPL_ENABLE_MPI:BOOL=ON \
  -DCMAKE_C_FLAGS:STRING="-m64 -g" \
  -DCMAKE_CXX_FLAGS:STRING="-m64 -g" \
  -DTrilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
  -DTrilinos_ENABLE_Zoltan:BOOL=ON \
  -DZoltan_ENABLE_ULLONG_IDS:Bool=ON \
  $ZOLTAN_SRC_DIR
make ${ZOLTAN_MAKE_FLAGS}
make install
cd -
# rm -rf ${ZOLTAN_SRC_DIR}
# rm -rf ${ZOLTAN_BUILD_DIR}