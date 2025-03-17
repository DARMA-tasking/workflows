
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
  default = "arm64"
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
    "linux/arm64"
  ]
}

target "build-all" {
  name = "build-${item.arch}-${item.distro}-${replace(item.distro_version, ".", "-")}-${item.compiler}-cpp"
  inherits = ["build"]

  args = {
    ARCH           = item.arch
    DISTRO         = item.distro
    DISTRO_VERSION = item.distro_version
    COMPILER       = item.compiler
    SETUP_ID = "${item.arch}-${item.distro}-${item.distro_version}-${item.compiler}-cpp"
  }

  matrix = {
    item = [
      {
        arch = "amd64"
        distro = "ubuntu"
        distro_version = "22.04"
        compiler = "clang-13"
        mpi = "mpich"
      },
      {
        arch = "amd64"
        distro = "ubuntu"
        distro_version = "22.04"
        compiler = "clang-14"
        mpi = "mpich"
      }

    ]
  }
}
