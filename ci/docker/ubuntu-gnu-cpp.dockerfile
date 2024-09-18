ARG arch=amd64
ARG ubuntu=20.04
FROM ${arch}/ubuntu:${ubuntu} as base

ARG proxy=""
ARG compiler=gcc-9
ARG ubuntu

ENV https_proxy=${proxy} \
    http_proxy=${proxy}

ENV DEBIAN_FRONTEND=noninteractive

ARG zoltan_enabled

RUN apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
    ${compiler} \
    g++-$(echo ${compiler} | cut -d- -f2) \
    ${zoltan_enabled:+gfortran-$(echo ${compiler} | cut -d- -f2)} \
    ca-certificates \
    ccache \
    curl \
    git \
    less \
    libomp5 \
    libunwind-dev \
    make-guile \
    ninja-build \
    valgrind \
    wget \
    zlib1g \
    zlib1g-dev \
    brotli \
    python3 \
    python3-brotli \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s \
    "$(which g++-$(echo ${compiler}  | cut -d- -f2))" \
    /usr/bin/g++

RUN ln -s \
    "$(which gcc-$(echo ${compiler}  | cut -d- -f2))" \
    /usr/bin/gcc

RUN if test ${zoltan_enabled} -eq 1; then \
      ln -s \
      "$(which gfortran-$(echo ${compiler}  | cut -d- -f2))" \
      /usr/bin/gfortran; \
    fi

ENV CC=gcc \
    CXX=g++

ARG arch

COPY ./ci/deps/cmake.sh cmake.sh
RUN ./cmake.sh 3.23.4 ${arch}

ENV PATH=/cmake/bin/:$PATH
ENV LESSCHARSET=utf-8

COPY ./ci/deps/mpich.sh mpich.sh
RUN if [ "$ubuntu" = "18.04" ]; then \
      ./mpich.sh 3.3.2 -j4; else \
      ./mpich.sh 4.0.2 -j4; \
    fi

ENV MPI_EXTRA_FLAGS="" \
    PATH=/usr/lib/ccache/:$PATH

ARG ZOLTAN_INSTALL_DIR=/trilinos-install
ENV ZOLTAN_DIR=${ZOLTAN_INSTALL_DIR}

COPY ./ci/deps/zoltan.sh zoltan.sh
RUN if test ${zoltan_enabled} -eq 1; then \
      ./zoltan.sh -j4 ${ZOLTAN_INSTALL_DIR}; \
    fi

RUN apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
    lcov && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip \
    && pip3 install schema deepdiff