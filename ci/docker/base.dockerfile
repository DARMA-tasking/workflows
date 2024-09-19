# Describes images with dependencies
ARG ARCH=amd64
ARG BASE=ubuntu:22.04
FROM ${ARCH}/${BASE} as base

RUN whoami

COPY ci/scripts /opt/scripts
RUN chmod u+x /opt/scripts/**/*.sh




# Install packages (works)
ARG PACKAGES=""
RUN echo $PACKAGES
ARG INSTALL_DEFAULT_PACKAGES=1
RUN /opt/scripts/deps/packages.sh "${PACKAGES}" ${INSTALL_DEFAULT_PACKAGES}

# Run additional setup commands
# ARG SETUP=""
# RUN bash -c "cd /opt/scripts/deps; \
#     readarray -td, instructions <<<"${SETUP}"; declare -p instructions; \
#     for cmd in \${instructions[@]}; \
#     do \
#         /opt/scripts/deps/\$cmd \
#     done\
#     "

RUN rm -rf /opt/scripts