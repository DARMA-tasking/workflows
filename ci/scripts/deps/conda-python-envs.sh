#!/usr/bin/env bash

set -exo pipefail

if test $# -lt 1
then
    echo "usage: ./$0 <csv_python_versions> <csv_pip_packages> <...>"
    exit 1
fi

python_versions=${1:-"3.8,3.9,3.10,3.11,3.12"}
pip_packages=${1:-"nanobind,yaml"}

readarray -td, python_versions_array <<<"$python_versions"; declare -p python_versions_array;
readarray -td, pip_packages_array <<<"$pip_packages"; declare -p pip_packages_array;

for v in ${python_versions_array[@]};
do
    conda create -y --no-default-package -n py$v
    conda activate py$v
    for p in ${python_versions_array[@]};
    do
        pip install $p
    done
done
# conda env remove -n py3.9$
conda env list
