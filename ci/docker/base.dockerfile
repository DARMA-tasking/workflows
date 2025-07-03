# Base dockerfile to build images used in Darma testing.

ARG REPO=lifflander1/vt
ARG ARCH=amd64
ARG BASE=ubuntu:22.04

FROM --platform=${ARCH} ${BASE} AS base

ARG SETUP_ID=${SETUP_ID:-"amd64-ubuntu-22.04-gcc-12-cpp"}

# YAML configuration string with dependencies to install
ARG DEPS=""

# Compiler
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG FC=${FC:-""}

# MPI
ARG MPI_EXTRA_FLAGS=${MPI_EXTRA_FLAGS:-""}

# PATH
ARG PATH_PREFIX=${PATH_PREFIX:-""}

# Packages to install
ARG PACKAGES=${PACKAGES:-""}

# Specific (Intel One API)
ARG LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}

# Setup environment variables
ENV DEBIAN_FRONTEND=noninteractive

ENV WF_SETUP_ID=${SETUP_ID}

ENV CC=$CC \
    CXX=$CXX \
    FC=$FC \
    \
    MPI_EXTRA_FLAGS=$MPI_EXTRA_FLAGS \
    \
    PATH="${PATH_PREFIX}${PATH}"

ENV CCACHE_COMPILERCHECK=content \
    CCACHE_COMPRESS=1  \
    CCACHE_MAXSIZE=200M \
    CCACHE_DIR=/build/ccache \
    \
    LESSCHARSET=utf-8 \
    \
    VTK_DIR=/opt/vtk/build \
    ZOLTAN_DIR=/opt/trilinos/bin

# Specific (Intel One API)
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH

# Prepare working directory
ARG WF_TMP_DIR=/opt/workflows

# Run the setup scripts
RUN --mount=type=bind,source=ci,target=${WF_TMP_DIR} \
    sh ${WF_TMP_DIR}/setup-basic.sh ${PACKAGES}

RUN --mount=type=bind,rw,source=ci,target=${WF_TMP_DIR} \
    BUILD_DEPS=${DEPS} python3 ${WF_TMP_DIR}/build-setup.py ${SETUP_ID} && \
    sh ${WF_TMP_DIR}/setup-${SETUP_ID}.sh
