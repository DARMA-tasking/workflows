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

# Environment
ENV PATH=/opt/cmake/bin:$PATH
ENV CC=$CC
ENV CXX=$CXX
ENV MPICH_CC=$MPICH_CC
ENV MPICH_CXX=$MPICH_CXX
ENV GCOV=$GCOV
ENV CONDA_INSTALL_DIR=/opt/conda
ENV CONDA_AUTO_ACTIVATE_BASE=false
ENV VTK_DIR=/opt/vtk/build
ENV DOCKER_RUN=1

COPY ci/shared/scripts/setup-${SETUP_ID}.sh setup.sh

RUN chmod +x setup.sh && ./setup.sh
