# Base dockerfile to build images used in Darma testing.

ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG SETUP_ID=${SETUP_ID:-"ubuntu-develop"}
ARG CI=${CI:-""}

ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG FC=${FC:-""}

ARG CPATH=${CPATH:-""}
ARG INFOPATH=${INFOPATH:-""}
ARG LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
ARG LIBRARY_PATH=${LIBRARY_PATH:-""}

ARG CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-""}
ARG CMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD:-""}
ARG CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-""}

ARG MPICH_CC=${MPICH_CC:-""}
ARG MPICH_CXX=${MPICH_CXX:-""}

# Add to path optional dependencies path
ARG PATH_PREFIX=${PATH_PREFIX:-""}

## Specific (Intel)
ARG CMPLR_ROOT \
    INTEL_LICENSE_FILE \
    ONEAPI_ROOT \
    TBBROOT

FROM --platform=${ARCH} ${BASE} as base

# ARGS
## Common
ARG SETUP_ID \
    CI \
    CC \
    CXX \
    GCOV \
    \
    CMAKE_BUILD_TYPE \
    CMAKE_CXX_STANDARD \
    CMAKE_PREFIX_PATH \
    \
    CPATH \
    INFOPATH \
    LIBRARY_PATH \
    LD_LIBRARY_PATH \
    MPICH_CC \
    MPICH_CXX \
    PATH_PREFIX
## Specific (Intel)
ARG CMPLR_ROOT \
    INTEL_LICENSE_FILE \
    ONEAPI_ROOT \
    TBBROOT

# ENV
## Common
ENV DOCKER_RUN=1 \
    CI=$CI \
    CC=$CC \
    CXX=$CXX \
    GCOV=$GCOV \
    \
    CONDA_INSTALL_DIR=/opt/conda \
    CONDA_AUTO_ACTIVATE_BASE=false \
    \
    VTK_DIR=/opt/vtk/build \
    \
    ZOLTAN_INSTALL_DIR=/opt/trilinos/bin \
    \
    LESSCHARSET=utf-8 \
    \
    CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
    CMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD \
    CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH \
    \
    CPATH=$CPATH \
    INFOPATH=$INFOPATH \
    LIBRARY_PATH=$LIBRARY_PATH \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH \
    MPICH_CC=$MPICH_CC \
    MPICH_CXX=$MPICH_CXX \
    PATH="${PATH_PREFIX}${PATH}"

# Specific (Intel One API)
ENV CMPLR_ROOT=$CMPLR_ROOT \
    INTEL_LICENSE_FILE=$INTEL_LICENSE_FILE \
    ONEAPI_ROOT=$ONEAPI_ROOT \
    TBBROOT=$TBBROOT

COPY ci/shared/scripts/setup-${SETUP_ID}.sh setup.sh

RUN chmod +x setup.sh && . ./setup.sh
