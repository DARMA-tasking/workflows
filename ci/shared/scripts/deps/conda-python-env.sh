#!/usr/bin/env bash

if test $# -lt 1
then
    echo "usage: ./$0 \"<python_version>\" \"<pip_packages_1 pip_packages_2 ...>\""
    exit 1
fi

set -exo pipefail

PYTHON_VERSION=$1
PIP_PACKAGES=${2:-""}

. /opt/conda/etc/profile.d/conda.sh

conda create -y --no-default-package -n py$PYTHON_VERSION
conda activate py$PYTHON_VERSION

if [ $PIP_PACKAGES != "" ]
then
    pip install $PIP_PACKAGES
fi

conda deactivate
