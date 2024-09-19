# Docker instructions to build an image with some arguments to specify compilers, python and VTK versions.
# @see .github/workflows/pushbasedockerimage.yml

ARG BASE_IMAGE=ubuntu:22.04

# Base image & requirements
FROM ${BASE_IMAGE} AS base

# Arguments
ARG VTK_VERSION=9.2.2
ARG PYTHON_VERSIONS=3.8,3.9,3.10,3.11,3.12
ARG CC=gcc-11
ARG CXX=g++-11
ARG GCOV=gcov-11

ENV DEBIAN_FRONTEND=noninteractive

# Setup common tools and compiler
RUN apt-get update -y -q && \
  apt-get install -y -q --no-install-recommends \
  ${CC} \
  ${CXX} \
  git \
  xz-utils \
  bzip2 \
  zip \
  gpg \
  wget \
  gpgconf \
  software-properties-common \
  libsigsegv2 \
  libsigsegv-dev \
  pkg-config \
  zlib1g \
  zlib1g-dev \
  m4 \
  gfortran-11 \
  make \
  cmake-data \
  cmake \
  pkg-config \
  libncurses5-dev \
  m4 \
  perl \
  curl \
  xvfb \
  lcov

# Setup MESA (opengl)
RUN bash /opt/scripts/setup_mesa.sh
RUN xvfb-run bash -c "glxinfo | grep 'OpenGL version'"

# Environment variables (conda path, python environments, compiler path, vtk)
ENV CC=/usr/bin/$CC
ENV CXX=/usr/bin/$CXX
ENV GCOV=/usr/bin/$GCOV
ENV CONDA_PATH=/opt/conda
ENV VTK_DIR=/opt/build/vtk

# Setup conda with python environments
RUN bash /opt/scripts/setup_conda.sh ${PYTHON_VERSIONS}

# Setup VTK
RUN VTK_VERSION=${VTK_VERSION} \
  VTK_DIR=${VTK_DIR} \
  VTK_SRC_DIR=/opt/src/vtk \
  bash /opt/scripts/setup_vtk.sh

# Clean apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "Base creation success"