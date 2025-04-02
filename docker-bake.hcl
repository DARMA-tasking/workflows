
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
        "python3-yaml",
        "python3",
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
    MPI_EXTRA_FLAGS = mpi-extra-flags(item)
    PATH_PREFIX     = path-prefix(item)
    PACKAGES        = packages(item)
  }

  matrix = {
    item = [
      # Ubuntu
      {
        compiler = "clang-9"
        distro_version = "20.04"
      },
      {
        compiler = "clang-10"
        distro_version = "20.04"
      },
      {
        compiler = "clang-11"
      },
      {
        compiler = "clang-12"
      },
      {
        compiler = "clang-13"
        extra_packages = "llvm-13"
      },
      {
        compiler = "clang-14"
        extra_packages = "llvm-14"
      },
      {
        compiler = "clang-15"
      },
      {
        compiler = "clang-16"
        distro_version = "24.04"
        extra_packages = "llvm-16"
      },
      {
        compiler = "clang-16"
        distro_version = "24.04"
        extra_packages = "llvm-16 xvfb"
        variant = "vtk"
      },
      {
        compiler = "clang-16"
        distro_version = "24.04"
        extra_packages = "llvm-16 gfortran-13"
        fc="gfortran-13"
        variant = "zoltan"
      },
      {
        compiler = "clang-17"
        distro_version = "24.04"
      },
      {
        compiler = "clang-18"
        distro_version = "24.04"
      },
      {
        compiler = "gcc-9"
        distro_version = "20.04"
        extra_packages = "python3-jinja2 python3-pygments"
      },
      {
        compiler = "gcc-10"
        distro_version = "20.04"
      },
      {
        compiler = "gcc-10"
        distro_version = "20.04"
        mpi_extra_flags = "--allow-run-as-root --oversubscribe"
        variant = "openmpi"
      },
      {
        compiler = "gcc-11"
      },
      {
        compiler = "gcc-12"
        extra_packages = "gcovr lcov"
      },
      {
        compiler = "gcc-12"
        extra_packages = "gcovr lcov xvfb"
        variant = "vtk"
      },
      {
        compiler = "gcc-12"
        extra_packages = "gcovr lcov gfortran-12"
        fc="gfortran-12"
        variant = "zoltan"
      },
      {
        compiler = "gcc-13"
        distro_version = "24.04"
      },
      {
        compiler = "gcc-14"
        distro_version = "24.04"
      },
      # Alpine
      {
        compiler = "clang"
        distro = "alpine"
        distro_version = "3.16"
        extra_packages = "clang-dev"
      },
      # CUDA
      {
        compiler = "gcc-9"
        distro = "nvidia/cuda"
        distro_version = "12.2.0-devel-ubuntu20.04"
        path_prefix = "/opt/nvcc_wrapper/build:"
        variant = "cuda-12.2.0"
      },
      {
        compiler = "gcc-9"
        distro = "nvidia/cuda"
        distro_version = "11.2.2-devel-ubuntu20.04"
        path_prefix = "/opt/nvcc_wrapper/build:"
        variant = "cuda-11.2.2"
      },
      # Intel
      {
        compiler = "icpc"
        distro = "intel/oneapi"
        distro_version = "os-tools-ubuntu20.04"
        extra_packages = "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2022.2.1"
        path_prefix = "/opt/intel/oneapi/dev-utilities/latest/bin:/opt/intel/oneapi/compiler/latest/linux/bin/intel64:/opt/intel/oneapi/compiler/latest/linux/bin:"
      },
      {
        compiler = "icpx"
        distro = "intel/oneapi"
        distro_version = "os-tools-ubuntu20.04"
        extra_packages = "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2022.2.1"
        path_prefix = "/opt/intel/oneapi/dev-utilities/latest/bin:/opt/intel/oneapi/compiler/latest/linux/bin/intel64:/opt/intel/oneapi/compiler/latest/linux/bin:"
      },
    ]
  }
}
