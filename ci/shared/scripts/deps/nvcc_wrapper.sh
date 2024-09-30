#!/usr/bin/env bash

set -exo pipefail

mkdir -p /opt/nvcc_wrapper/bin

wget https://raw.githubusercontent.com/kokkos/kokkos/master/bin/nvcc_wrapper -P /opt/nvcc_wrapper/bin
chmod +x /opt/nvcc_wrapper/bin/nvcc_wrapper

which nvcc_wrapper