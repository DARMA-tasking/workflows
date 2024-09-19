#!/usr/bin/env bash

set -exo pipefail

if test $# -lt 1
then
    echo "usage: ./$0 <csv_python_versions> <csv_pip_packages> <...>"
    exit 1
fi

python_version=$1
pip_packages=${2:-"nanobind,yaml"}

readarray -td, pip_packages_array <<<"$pip_packages"; declare -p pip_packages_array;

conda create -y --no-default-package -n py$python_version
conda activate py$python_version

for p in ${pip_packages_array[@]};
do
    pip install $p
done

conda deactivate
