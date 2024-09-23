#!/bin/bash

# This script installs Conda and setup conda environments on the host machine for the given python versions
# Example: `setup_conda.sh 3.8,3.9,3.10,3.11,3.12` will
# 1. Setup conda
# 2. Create conda environments py3.8, py3.9, py3.10, py3.11, py3.12 (with python version and nanobind package)

CONDA_INSTALL_DIR=${CONDA_INSTALL_DIR:-"/opt/conda"}

echo "Installing conda..."
mkdir -p ~/miniconda3
if [[ $(uname -a) == *"Darwin"* ]]; then
    if [[ $(arch) == 'arm64' ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda.sh
    else
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o ~/miniconda.sh
    fi
else
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh
fi
bash ~/miniconda.sh -b -u -p $CONDA_INSTALL_DIR
rm -rf ~/miniconda.sh

$CONDA_INSTALL_DIR/bin/conda init bash
$CONDA_INSTALL_DIR/bin/conda init zsh
if [ -f ~/.zshrc ]; then . ~/.zshrc; fi
if [ -f ~/.profile ]; then . ~/.profile; fi
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

echo "Conda path: $(which conda)"
echo "Conda version: $(conda --version)"
