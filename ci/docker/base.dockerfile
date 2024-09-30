# Build an image with some configured packages and dependencies

ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG SETUP_ID=${SETUP_ID:-"ubuntu-develop"}
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG MPICH_CC=${MPICH_CC:-""}
ARG MPICH_CXX=${MPICH_CXX:-""}
ARG FC=${FC:-""}

FROM --platform=${ARCH} ${BASE} as base

ARG SETUP_ID
ARG CC
ARG CXX
ARG GCOV
ARG MPICH_CC
ARG MPICH_CXX

ARG CMAKE_BUILD_TYPE
ARG CMAKE_CXX_STANDARD

# Environment
ENV DOCKER_RUN=1 \
    CC=$CC \
    CXX=$CXX \
    MPICH_CC=$MPICH_CC \
    MPICH_CXX=$MPICH_CXX \
    GCOV=$GCOV \
    \
    CONDA_INSTALL_DIR=/opt/conda \
    CONDA_AUTO_ACTIVATE_BASE=false \
    \
    VTK_DIR=/opt/vtk/build \
    \
    LESSCHARSET=utf-8 \
    \
    PATH=/opt/cmake/bin:/opt/nvcc_wrapper/bin:/opt/vtk/bin:$PATH

COPY ci/shared/scripts/setup-${SETUP_ID}.sh setup.sh

RUN chmod +x setup.sh && . ./setup.sh

RUN echo "CXX=$CXX"
