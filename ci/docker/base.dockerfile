# Base dockerfile to build images used in Darma testing.

ARG REPO=lifflander1/vt
ARG ARCH=amd64
ARG BASE=ubuntu:22.04

FROM --platform=${ARCH} ${BASE} AS base

ARG SETUP_ID=${SETUP_ID:-"amd64-ubuntu-22.04-gcc-12-cpp"}

# Compiler
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG FC=${FC:-""}

# MPI
ARG MPICH_CC=${MPICH_CC:-""}
ARG MPICH_CXX=${MPICH_CXX:-""}
ARG MPI_EXTRA_FLAGS=${MPI_EXTRA_FLAGS:-""}

# PATH
ARG PATH_PREFIX=${PATH_PREFIX:-""}

ARG PACKAGES=${PACKAGES:-""}

# Specific (Intel One API)
ARG CMPLR_ROOT \
    INTEL_LICENSE_FILE \
    ONEAPI_ROOT \
    TBBROOT \
    \
    CPATH=${CPATH:-""} \
    INFOPATH=${INFOPATH:-""} \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""} \
    LIBRARY_PATH=${LIBRARY_PATH:-""}

# Setup environment variables
ENV DEBIAN_FRONTEND=noninteractive

ENV WF_SETUP_ID=${SETUP_ID}

ENV CC=$CC \
    CXX=$CXX \
    FC=$FC \
    \
    MPICH_CC=$MPICH_CC \
    MPICH_CXX=$MPICH_CXX \
    MPI_EXTRA_FLAGS=$MPI_EXTRA_FLAGS \
    \
    PATH="${PATH_PREFIX}${PATH}"

ENV CCACHE_COMPILERCHECK=content \
    CCACHE_COMPRESS=1  \
    CCACHE_COMPRESSLEVE=5  \
    CCACHE_MAXSIZE=700M \
    CCACHE_DIR=/build/ccache \
    \
    LESSCHARSET=utf-8 \
    \
    VTK_DIR=/opt/vtk/build \
    ZOLTAN_DIR=/opt/trilinos/bin

# Specific (Intel One API)
ENV CMPLR_ROOT=$CMPLR_ROOT \
    INTEL_LICENSE_FILE=$INTEL_LICENSE_FILE \
    ONEAPI_ROOT=$ONEAPI_ROOT \
    TBBROOT=$TBBROOT \
    \
    CPATH=$CPATH \
    INFOPATH=$INFOPATH \
    LIBRARY_PATH=$LIBRARY_PATH \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH

# Prepare working directory
ARG WF_TMP_DIR=/opt/workflows

# Run the setup scripts
RUN --mount=type=bind,source=ci,target=${WF_TMP_DIR} \
    sh ${WF_TMP_DIR}/setup-basic.sh ${PACKAGES}

RUN --mount=type=bind,rw,source=ci,target=${WF_TMP_DIR} \
    python3 ${WF_TMP_DIR}/build-setup.py ${REPO}:wf-${SETUP_ID} && \
    sh ${WF_TMP_DIR}/setup-${SETUP_ID}.sh
