# Build an image with some configured packages and dependencies
ARG ARCH=amd64
ARG BASE=ubuntu:22.04
FROM ${ARCH}/${BASE} as base

# Copy setup scripts
COPY ci/scripts/deps /opt/scripts/install
RUN ls /opt/scripts/install
RUN chmod u+x /opt/scripts/install/*.sh

# Install packages (works)
ARG PACKAGES=""
ARG INSTALL_DEFAULT_PACKAGES=1
RUN /opt/scripts/install/packages.sh "${PACKAGES}" ${INSTALL_DEFAULT_PACKAGES}

# Run additional setup commands from setup file
ARG SETUP_FILE=""
RUN /opt/scripts/install/${SETUP_FILE}

# Clean
RUN rm -rf /opt/scripts