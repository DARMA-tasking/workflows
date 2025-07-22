
variable "COMPILER" {
  default = "clang-14"
}

variable "HOST_COMPILER" {
  default = "clang-14"
}

variable "REPO" {
  default = "lifflander1/vt"
}

variable "ARCH" {
  default = "amd64"
}

variable "DISTRO" {
  default = "ubuntu"

  validation {
    condition = DISTRO == "ubuntu" || DISTRO == "alpine"
    error_message = "Supported configurations are ubuntu and alpine"
  }
}

variable "DISTRO_VERSION" {
  default = "22.04"
}

function base-packages {
  params = [item]
  result = (
    equal(distro(item), "ubuntu") || equal(distro(item), "nvidia/cuda") || equal(distro(item), "intel/oneapi") ?
      join(" ", [
        "ca-certificates",
        "ccache",
        "curl",
        "git",
        "jq",
        "lcov",
        "less",
        "libomp5",
        "libunwind-dev",
        "make-guile",
        "ninja-build",
        "python3",
        "python3-brotli",
        "python3-deepdiff",
        "python3-schema",
        "python3-yaml",
        "valgrind",
        "wget",
        "zlib1g-dev",
      ]) :
      join(" ", [
        "alpine-sdk",
        "autoconf",
        "automake",
        "bash",
        "binutils-dev",
        "ccache",
        "cmake",
        "dpkg",
        "gcovr",
        "git",
        "libdwarf-dev",
        "libtool",
        "libunwind-dev",
        "linux-headers",
        "m4",
        "make",
        "ninja",
        "py3-yaml",
        "python3",
        "wget",
        "zlib-dev",
      ])
  )
}

function "arch" {
  params = [item]
  result = lookup(item, "arch", ARCH)
}

function "base" {
  params = [item]
  result = "${distro(item)}:${distro-version(item)}"
}

function "distro" {
  params = [item]
  result = lookup(item, "distro", DISTRO)
}

function "distro-version" {
  params = [item]
  result = lookup(item, "distro_version", DISTRO_VERSION)
}

function "compiler" {
  params = [item]
  result = lookup(item, "compiler", COMPILER)
}

function "cc" {
  params = [item]
  result = replace(lookup(item, "compiler", COMPILER), "icp", "ic")
}

function "cxx" {
  params = [item]
  result = replace(
    replace(compiler(item), "gcc", "g++"),
    "clang", "clang++"
  )
}

function "fc" {
  params = [item]
  result = lookup(item, "fc", "")
}

function "variant" {
  params = [item]
  result = lookup(item, "variant", "")
}

function "packages" {
  params = [item]
  result = join(" ", [
    equal(distro(item), "intel/oneapi") ? "" : cc(item),
    equal(distro(item), "intel/oneapi") || equal(distro(item), "alpine") ?
      "" : cxx(item),
    base-packages(item),
    extra-packages(item),
  ])
}

function "extra-packages" {
  params = [item]
  result = lookup(item, "extra_packages", "")
}

function "path-prefix" {
  params = [item]
  result = "${lookup(item, "path_prefix", "")}/usr/lib/ccache:/opt/cmake/bin:"
}

function "mpi-extra-flags" {
  params = [item]
  result = lookup(item, "mpi_extra_flags", "")
}

function "ld-library-path" {
  params = [item]
  result = lookup(item, "ld_library_path", "")
}

function "deps" {
  params = [item]
  result = lookup(item, "deps", "")
}

function "vt_ldms" {
  params = [item]
  result = lookup(item, "vt_ldms", "")
}

function "setup-id" {
  params = [item]
  result = join("-", [
    arch(item),
    equal(distro(item), "nvidia/cuda") || equal(distro(item), "intel/oneapi") ?
      "ubuntu-20.04" :
      "${distro(item)}-${distro-version(item)}",
    compiler(item),
    equal(variant(item), "") ? "cpp" : "${variant(item)}-cpp"
  ])
}

target "build" {
  args = {
    REPO = "${REPO}"
  }
  target = "base"
  context = "."
  dockerfile = "ci/docker/base.dockerfile"
  platforms = [
    "linux/amd64"
  ]
}

target "build-all" {
  name = replace(setup-id(item), ".", "-")
  inherits = ["build"]
  tags = ["${REPO}:wf-${setup-id(item)}"]

  args = {
    ARCH            = arch(item)
    BASE            = base(item)
    DISTRO          = distro(item)
    DISTRO_VERSION  = distro-version(item)
    COMPILER        = compiler(item)
    SETUP_ID        = setup-id(item)
    CC              = cc(item)
    CXX             = equal(distro(item), "nvidia/cuda") ? "nvcc_wrapper" : cxx(item)
    FC              = fc(item)
    LD_LIBRARY_PATH = ld-library-path(item)
    MPI_EXTRA_FLAGS = mpi-extra-flags(item)
    PATH_PREFIX     = path-prefix(item)
    PACKAGES        = packages(item)
    DEPS            = deps(item)
  }

  matrix = {
    item = [
      # Ubuntu
      {
        compiler = "clang-9"
        distro_version = "20.04"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-10"
        distro_version = "20.04"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-11"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-12"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-13"
        extra_packages = "llvm-13"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-14"
        extra_packages = "llvm-14"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-15"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-16"
        distro_version = "24.04"
        extra_packages = "llvm-16"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-16"
        distro_version = "24.04"
        extra_packages = "llvm-16 xvfb"
        variant = "vtk"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
          mesa: ~
          vtk: '9.3.1'
        EOF
      },
      {
        compiler = "clang-16"
        distro_version = "24.04"
        extra_packages = "llvm-16 gfortran-13"
        fc="gfortran-13"
        variant = "zoltan"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
          zoltan: [ -j4 ]
        EOF
      },
      {
        compiler = "clang-17"
        distro_version = "24.04"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "clang-18"
        distro_version = "24.04"
        deps = <<EOF
          cmake: ['3.23.4']
          libunwind: '1.6.2'
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "gcc-9"
        distro_version = "20.04"
        path_prefix = "/opt/doxygen/bin:"
        extra_packages = "python3-jinja2 python3-pygments"
        deps = <<EOF
          cmake: ['3.23.4']
          doxygen: ['1.8.16']
          mpich: [ '4.0.2', '-j4' ]
        EOF
      },
      {
        compiler = "gcc-10"
        distro_version = "20.04"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "gcc-10"
        distro_version = "20.04"
        extra_packages = "ssh"
        mpi_extra_flags = "--allow-run-as-root --oversubscribe"
        variant = "openmpi"
        deps = <<EOF
          cmake: ['3.23.4']
          openmpi: ['v4.0', '4.0.4', '-j4']
        EOF
      },
      {
        compiler = "gcc-11"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "gcc-12"
        extra_packages = "gcovr lcov"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "gcc-12"
        extra_packages = "gcovr lcov xvfb"
        variant = "vtk"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
          mesa: ~
          vtk: '9.3.1'
        EOF
      },
      {
        compiler = "gcc-12"
        extra_packages = "gcovr lcov gfortran-12"
        fc="gfortran-12"
        variant = "zoltan"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
          zoltan: [ -j4 ]
        EOF
      },
      {
        compiler = "gcc-13"
        distro_version = "24.04"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
        EOF
      },
      {
        compiler = "gcc-14"
        distro_version = "24.04"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
        EOF
      },
      # Alpine
      {
        compiler = "clang"
        distro = "alpine"
        distro_version = "3.16"
        extra_packages = "clang-dev"
        deps = <<EOF
          mpich: [ '3.3.2', '-j4' ]
        EOF
      },
      # CUDA
      {
        compiler = "gcc-9"
        distro = "nvidia/cuda"
        distro_version = "12.2.0-devel-ubuntu20.04"
        path_prefix = "/opt/nvcc_wrapper/build:"
        variant = "cuda-12.2.0"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: { env: { CC: gcc-9, CXX: g++-9 }, args: ['4.0.2', '-j4'] }
          nvcc_wrapper: ~
        EOF
      },
      {
        compiler = "gcc-9"
        distro = "nvidia/cuda"
        distro_version = "11.4.3-devel-ubuntu20.04"
        path_prefix = "/opt/nvcc_wrapper/build:"
        variant = "cuda-11.4.3"
        deps = <<EOF
          cmake: ['3.23.4']
          fmt: { env: { CC: gcc-9, CXX: g++-9 }, args: ['11.1.3', '-j4'] }
          mpich: { env: { CC: gcc-9, CXX: g++-9 }, args: ['4.0.2', '-j4'] }
          nvcc_wrapper: ~
        EOF
      },
      # Intel
      {
        compiler = "icpx"
        distro = "intel/oneapi"
        distro_version = "os-tools-ubuntu20.04"
        extra_packages = "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2022.2.1"
        ld_library_path = "/opt/intel/oneapi/tbb/latest/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/debugger/10.1.1/dep/lib:/opt/intel/oneapi/debugger/10.1.1/libipt/intel64/lib:/opt/intel/oneapi/debugger/10.1.1/gdb/intel64/lib:/opt/intel/oneapi/compiler/latest/linux/lib:/opt/intel/oneapi/compiler/latest/linux/lib/x64:/opt/intel/oneapi/compiler/latest/linux/lib/emu:/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin:/opt/intel/oneapi/compiler/latest/linux/compiler/lib"
        path_prefix = "/opt/intel/oneapi/dev-utilities/latest/bin:/opt/intel/oneapi/compiler/latest/linux/bin/intel64:/opt/intel/oneapi/compiler/latest/linux/bin:"
        deps = <<EOF
          cmake: ['3.23.4']
          mpich: ['4.0.2', '-j4']
        EOF
      },
      #LDMS
      {
        compiler = "gcc-13"
        distro_version = "24.04"
        variant = "ldms"
        deps = <<EOF
          cmake: ['3.28.3']
          mpich: ['4.0.2', '-j4']
          ldms: ['4.3.5'] #latest: 5.1.2
        EOF
      }
    ]
  }
}
