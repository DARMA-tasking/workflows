# Build an image with some configured packages and dependencies

ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG SETUP_ID=${SETUP_ID:-"ubuntu-develop"}
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG FC=${FC:-""}

FROM ${ARCH}/${BASE} as base

# setup script requirements
RUN apt-get update && \
    apt-get install -y wget git

ARG SETUP_ID
ARG CC
ARG CXX
ARG GCOV

COPY ci/shared/scripts/setup-${SETUP_ID}.sh setup.sh
COPY ci/docker/post-setup.sh post-setup.sh

SHELL ["/bin/bash", "-c"]

# Environment
ENV PATH=/opt/cmake/bin:$PATH
ENV CC=$CC
ENV CXX=$CXX
ENV GCOV=$GCOV
ENV CONDA_INSTALL_DIR=/opt/conda
ENV CONDA_AUTO_ACTIVATE_BASE=false
ENV VTK_DIR=/opt/vtk/build

RUN bash setup.sh

# Docker finalize script
RUN bash post-setup.sh
