# Build an image with some configured packages and dependencies
ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}

FROM ${ARCH}/${BASE} as base

SHELL ["/bin/bash", "-c"]

# Copy setup scripts
COPY ci/scripts/deps /opt/scripts/install
RUN ls /opt/scripts/install
RUN chmod u+x /opt/scripts/install/*.sh

# Install packages (works)
ARG PACKAGES=""
ARG INSTALL_DEFAULT_PACKAGES=1
RUN /opt/scripts/install/packages.sh "${PACKAGES}" ${INSTALL_DEFAULT_PACKAGES}

# Environment variables (conda path, python environments, compiler, cmake path, vtk)
ENV PATH=/opt/cmake/bin:$PATH

ENV CC=$CC
ENV CXX=$CXX
ENV GCOV=$GCOV

ENV CONDA_INSTALL_DIR=/opt/conda
ENV CONDA_AUTO_ACTIVATE_BASE=false

ENV VTK_DIR=/opt/vtk/build

# Run additional setup commands from setup file
ARG SETUP_FILE=""
RUN /opt/scripts/install/${SETUP_FILE}

# Clean
RUN rm -rf /opt/scripts