# Base dockerfile to build images used in Darma testing.

ARG ARCH=amd64
ARG BASE=ubuntu:22.04
ARG SETUP_ID=${SETUP_ID:-"ubuntu-develop"}
ARG CC=${CC:-""}
ARG CXX=${CXX:-""}
ARG MPICH_CC=${MPICH_CC:-""}
ARG MPICH_CXX=${MPICH_CXX:-""}
ARG FC=${FC:-""}
ARG CI=${CI:-""}

FROM --platform=${ARCH} ${BASE} as base

ARG SETUP_ID \
    CI \
    CC \
    CXX \
    GCOV \
    CMAKE_BUILD_TYPE \
    CMAKE_CXX_STANDARD \
    MPICH_CC \
    MPICH_CXX

ENV DOCKER_RUN=1 \
    CI=$CI \
    CC=$CC \
    CXX=$CXX \
    MPICH_CC=$MPICH_CC \
    MPICH_CXX=$MPICH_CXX \
    GCOV=$GCOV \
    CONDA_INSTALL_DIR=/opt/conda \
    CONDA_AUTO_ACTIVATE_BASE=false \
    VTK_DIR=/opt/vtk/build \
    LESSCHARSET=utf-8 \
    PATH=/usr/lib/ccache:/opt/cmake/bin:/opt/nvcc_wrapper/bin:/opt/vtk/bin:$PATH \
    CMAKE_PREFIX_PATH=/opt/intel/oneapi/tbb/latest/env/.. \
    CMPLR_ROOT=/opt/intel/oneapi/compiler/latest  \
    CPATH=/opt/intel/oneapi/tbb/latest/env/../include:/opt/intel/oneapi/dev-utilities/latest/include:/opt/intel/oneapi/compiler/latest/linux/include  \
    INFOPATH=/opt/intel/oneapi/debugger/10.1.2/gdb/intel64/lib  \
    INTEL_LICENSE_FILE=/opt/intel/licenses:/root/intel/licenses:/opt/intel/licenses:/root/intel/licenses:/Users/Shared/Library/Application Support/Intel/Licenses  \
    LD_LIBRARY_PATH=/opt/intel/oneapi/tbb/latest/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/debugger/10.1.1/dep/lib:/opt/intel/oneapi/debugger/10.1.1/libipt/intel64/lib:/opt/intel/oneapi/debugger/10.1.1/gdb/intel64/lib:/opt/intel/oneapi/compiler/latest/linux/lib:/opt/intel/oneapi/compiler/latest/linux/lib/x64:/opt/intel/oneapi/compiler/latest/linux/lib/emu:/opt/intel/oneapi/compiler/latest/linux/lib/oclfpga/host/linux64/lib:/opt/intel/oneapi/compiler/latest/linux/lib/oclfpga/linux64/lib:/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin:/opt/intel/oneapi/compiler/latest/linux/compiler/lib  \
    LIBRARY_PATH=/opt/intel/oneapi/tbb/latest/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin:/opt/intel/oneapi/compiler/latest/linux/lib  \
    ONEAPI_ROOT=/opt/intel/oneapi \
    PATH=/opt/intel/oneapi/dev-utilities/latest/bin:/opt/intel/oneapi/debugger/10.1.1/gdb/intel64/bin:/opt/intel/oneapi/compiler/latest/linux/lib/oclfpga/llvm/aocl-bin:/opt/intel/oneapi/compiler/latest/linux/lib/oclfpga/bin:/opt/intel/oneapi/compiler/latest/linux/bin/intel64:/opt/intel/oneapi/compiler/latest/linux/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    TBBROOT=/opt/intel/oneapi/tbb/latest/env/..

COPY ci/shared/scripts/setup-${SETUP_ID}.sh setup.sh

RUN chmod +x setup.sh && . ./setup.sh
