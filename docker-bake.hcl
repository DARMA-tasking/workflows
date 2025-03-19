
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

function "arch" {
  params = [item]
  result = lookup(item, "arch", ARCH)
}

function "base" {
  params = [item]
  result = "${lookup(item, "distro", DISTRO)}:${lookup(item, "distro_version", DISTRO_VERSION)}"
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
    replace(
      lookup(item, "compiler", COMPILER),
      "gcc", "g++"
    ),
    "clang", "clang++"
  )
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
    PATH_PREFIX     = ""
    CPATH           = ""
    INFOPATH        = ""
    LIBRARY_PATH    = ""
    LD_LIBRARY_PATH = ""
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
      },
      {
        compiler = "clang-14"
      },
      {
        compiler = "clang-15"
      },
      {
        compiler = "clang-16"
        distro_version = "24.04"
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
