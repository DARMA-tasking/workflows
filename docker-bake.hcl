
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

function "build-setup-id" {
  params = [arch, distro, distro_version, compiler, variant]
  result = [
    "${variant == "" ? "${arch}-${distro}-${distro_version}-${compiler}-cpp" : "${arch}-${distro}-${distro_version}-${compiler}-${variant}-cpp"}"
  ]
}

target "build" {
  args = {
    ARCH = "${ARCH}"
    DISTRO = "${DISTRO}"
    DISTRO_VERSION = "${DISTRO_VERSION}"
    COMPILER = "${COMPILER}"
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
  name = "build-${lookup(item, "arch", ARCH)}-${lookup(item, "distro", DISTRO)}-${replace(lookup(item, "distro_version", DISTRO_VERSION), ".", "-")}-${lookup(item, "compiler", COMPILER)}-cpp"
  inherits = ["build"]

  args = {
    ARCH           = lookup(item, "arch", ARCH)
    DISTRO         = lookup(item, "distro", DISTRO)
    DISTRO_VERSION = lookup(item, "distro_version", DISTRO_VERSION)
    COMPILER       = lookup(item, "compiler", COMPILER)
    SETUP_ID = "${lookup(item, "arch", ARCH)}-${lookup(item, "distro", DISTRO)}-${lookup(item, "distro_version", DISTRO_VERSION)}-${lookup(item, "compiler", COMPILER)}-cpp"
  }

  matrix = {
    item = [
      {
        distro_version = "22.04"
        compiler = "clang-13"
        mpi = "mpich"
      },
      {
        distro_version = "22.04"
        compiler = "clang-14"
        mpi = "mpich"
      }

    ]
  }
}
