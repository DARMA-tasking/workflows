# Global template for each docker file to build and test a project
ARG ARCH=amd64
ARG BASE=ubuntu:22.04

FROM ${ARCH}/${BASE} as base

COPY ci/scripts /opt/scripts

# Setup common dependencies
RUN bash /opt/scripts/deps/common.sh
