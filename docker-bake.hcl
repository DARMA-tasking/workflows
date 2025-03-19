
variable "COMPILER_TYPE" {
  default = "clang"
}

variable "HOST_COMPILER" {
  default = "clang-14"
}

variable "COMPILER" {
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

variable BASE_PACKAGES {
  default = "ca-certificates wget git python3 python3-yaml ccache curl jq lcov less libomp5 libunwind-dev make-guile ninja-build valgrind zlib1g zlib1g-dev"
}

function "arch" {
  params = [item]
  result = lookup(item, "arch", ARCH)
}

function "base" {
  params = [item]
  result = "${distro(item)}:${distro_version(item)}"
}

function "distro" {
  params = [item]
  result = lookup(item, "distro", DISTRO)
}

function "distro_version" {
  params = [item]
  result = lookup(item, "distro_version", DISTRO_VERSION)
}

function "compiler" {
  params = [item]
  result = lookup(item, "compiler", COMPILER)
}

function "cc" {
  params = [item]
  result = lookup(item, "compiler", COMPILER)
}

function "cxx" {
  params = [item]
  result = replace(
    replace(compiler(item), "gcc", "g++"),
    "clang", "clang++"
  )
}

# FIXME: check distro
function "packages" {
  params = [item]
  result = "${cc(item)} ${cxx(item)} ${extra-packages(item)} ${BASE_PACKAGES}"
}

function "extra-packages" {
  params = [item]
  result = lookup(item, "extra_packages", "")
}

function "setup-id" {
  params = [item]
  result = "${arch(item)}-${distro(item)}-${distro_version(item)}-${compiler(item)}-cpp"
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
  name = replace("build-${setup-id(item)}", ".", "-")
  inherits = ["build"]

  args = {
    ARCH            = arch(item)
    BASE            = base(item)
    DISTRO          = distro(item)
    DISTRO_VERSION  = distro_version(item)
    COMPILER        = compiler(item)
    SETUP_ID        = setup-id(item)
    CC              = cc(item)
    CXX             = cxx(item)
    FC              = ""
    MPICH_CC        = ""
    MPICH_CXX       = ""
    CPATH           = ""
    INFOPATH        = ""
    LIBRARY_PATH    = ""
    LD_LIBRARY_PATH = ""
    PATH_PREFIX     = "/usr/lib/ccache:/opt/cmake/bin:"
    PACKAGES        = packages(item)
  }

  matrix = {
    item = [
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
        extra_packages = "g++-9 python3-jinja2 python3-pygments"
      },
      {
        compiler = "gcc-10"
        distro_version = "20.04"
      },
      {
        compiler = "gcc-11"
      },
      {
        compiler = "gcc-12"
        extra_packages = "gcovr lcov"
      },
      {
        compiler = "gcc-13"
        distro_version = "24.04"
      },
      {
        compiler = "gcc-14"
        distro_version = "24.04"
      }
    ]
  }
}
