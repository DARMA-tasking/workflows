# Base dockerfile to build images used in Darma testing.

ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG SETUP_ID=${SETUP_ID:-"ubuntu-develop"}
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG MPICH_CC=${MPICH_CC:-""}
ARG MPICH_CXX=${MPICH_CXX:-""}
ARG FC=${FC:-""}
ARG CI=${CI:-""}

FROM --platform=${ARCH} ${BASE} as base

ARG SETUP_ID \
    CI \
    CC \
    CXX \
    GCOV \
    CMAKE_BUILD_TYPE \
    CMAKE_CXX_STANDARD \
    MPICH_CC \
    MPICH_CXX

# Test environment variables
ENV DOCKER_RUN=1 \
    CI=$CI \
    CC=$CC \
    CXX=$CXX \
    MPICH_CC=$MPICH_CC \
    MPICH_CXX=$MPICH_CXX \
    GCOV=$GCOV \
    CONDA_INSTALL_DIR=/opt/conda \
    CONDA_AUTO_ACTIVATE_BASE=false \
    VTK_DIR=/opt/vtk/build \
    LESSCHARSET=utf-8 \
    PATH=/usr/lib/ccache:/opt/cmake/bin:/opt/nvcc_wrapper/bin:/opt/vtk/bin:$PATH

COPY ci/shared/scripts/setup-${SETUP_ID}.sh setup.sh

RUN chmod +x setup.sh && . ./setup.sh
