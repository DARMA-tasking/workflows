ARG arch=amd64
ARG ubuntu=20.04
FROM ${arch}/ubuntu:${ubuntu} as base

ARG proxy=""
ARG compiler=clang-11
ARG ubsan_enabled
ARG ubuntu

ENV https_proxy=${proxy} \
    http_proxy=${proxy}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
    ${compiler} \
    ${ubsan_enabled:+llvm-$(echo ${compiler} | cut -d- -f2)} \
    ca-certificates \
    ccache \
    curl \
    git \
    less \
    libomp-dev \
    libomp5 \
    make-guile \
    ninja-build \
    python3 \
    valgrind \
    wget \
    zlib1g \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s \
    "$(which $(echo ${compiler}  | cut -d- -f1)++-$(echo ${compiler}  | cut -d- -f2))" \
    /usr/bin/clang++

ENV CC=${compiler} \
    CXX=clang++

COPY ./ci/deps/libunwind.sh libunwind.sh
RUN ./libunwind.sh 1.6.2

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
    CMAKE_PREFIX_PATH="/lib/x86_64-linux-gnu/" \
    PATH=/usr/lib/ccache/:$PATH \
    CMAKE_EXE_LINKER_FLAGS="-pthread"
