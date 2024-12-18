# Base dockerfile to build images used in Darma testing.

ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG SETUP_ID=${SETUP_ID:-"ubuntu-develop"}

# Compiler
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG FC=${FC:-""}

# MPI
ARG MPICH_CC=${MPICH_CC:-""}
ARG MPICH_CXX=${MPICH_CXX:-""}

# PATH
ARG PATH_PREFIX=${PATH_PREFIX:-""}

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

FROM --platform=${ARCH} ${BASE} AS base

ARG SETUP_ID CC CXX FC MPICH_CC MPICH_CXX PATH_PREFIX
# Specific (Intel One API)
ARG CMPLR_ROOT INTEL_LICENSE_FILE ONEAPI_ROOT TBBROOT CPATH INFOPATH LIBRARY_PATH LD_LIBRARY_PATH


# Copy dependency scripts
ENV WF_TMP_DIR=/opt/workflows
ADD ci/shared/scripts/deps ${WF_TMP_DIR}/deps

# Setup environment variables
ENV DEBIAN_FRONTEND=noninteractive

ENV SCRIPTS_INSTALL_DIR=${SCRIPTS_INSTALL_DIR}

ENV WF_DOCKER=1 \
    WF_SETUP_ID=${SETUP_ID}

ENV CC=$CC \
    CXX=$CXX \
    FC=$FC \
    \
    MPICH_CC=$MPICH_CC \
    MPICH_CXX=$MPICH_CXX \
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

COPY ci/shared/scripts/setup-${SETUP_ID}.sh ${WF_TMP_DIR}/setup.sh
RUN chmod +x ${WF_TMP_DIR}/setup.sh && . ${WF_TMP_DIR}/setup.sh

# Clean
RUN rm -rf $WF_TMP_DIR
