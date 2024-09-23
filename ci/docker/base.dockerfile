# Build an image with some configured packages and dependencies
ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG CI_ENVIRONMENT=${CXX:-"ubuntu-develop"}

FROM ${ARCH}/${BASE} as base

SHELL ["/bin/bash", "-c"]

# Copy setup scripts
ARG CI_ENVIRONMENT
COPY ci/shared/scripts/setup-${CI_ENVIRONMENT}.sh /opt/scripts/setup.sh
COPY ci/shared/scripts/deps /opt/scripts/deps
RUN chmod u+x /opt/scripts/setup.sh /opt/scripts/deps/*.sh

# Environment variables (conda path, python environments, compiler, cmake path, vtk)
ENV PATH=/opt/cmake/bin:$PATH
ENV CC=$CC
ENV CXX=$CXX
ENV GCOV=$GCOV
ENV CONDA_INSTALL_DIR=/opt/conda
ENV CONDA_AUTO_ACTIVATE_BASE=false
ENV VTK_DIR=/opt/vtk/build

# Run setup script
RUN /opt/scripts/setup.sh

# Clean
RUN rm -rf /opt/scripts