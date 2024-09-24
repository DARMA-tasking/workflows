# Build an image with some configured packages and dependencies
ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG CI_ENVIRONMENT=${CXX:-"ubuntu-develop"}

FROM ${ARCH}/${BASE} as base

# setup script requirements
RUN apt-get update && \
    apt-get install -y wget git

ARG CI_ENVIRONMENT
COPY ci/shared/scripts/setup-${CI_ENVIRONMENT}.sh setup.sh

SHELL ["/bin/bash", "-c"]

# Environment variables (conda path, python environments, compiler, cmake path, vtk)
ENV PATH=/opt/cmake/bin:$PATH
ENV CC=$CC
ENV CXX=$CXX
ENV GCOV=$GCOV
ENV CONDA_INSTALL_DIR=/opt/conda
ENV CONDA_AUTO_ACTIVATE_BASE=false
ENV VTK_DIR=/opt/vtk/build

# Setup
RUN bash setup.sh
