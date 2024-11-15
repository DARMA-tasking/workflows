#!/usr/bin/env bash

set -exo pipefail

mkdir -p /opt/nvcc_wrapper/build

wget https://raw.githubusercontent.com/kokkos/kokkos/master/bin/nvcc_wrapper -P /opt/nvcc_wrapper/build
chmod +x /opt/nvcc_wrapper/build/nvcc_wrapper

which nvcc_wrapper