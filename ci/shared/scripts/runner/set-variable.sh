#!/usr/bin/env sh

# Set a variable in the parent Github or Azure runner

if [ -n "$GITHUB_ENV" ]
then
    echo "Set GITHUB variable $1=$2"
    echo "$1=$2" >> $GITHUB_ENV
elif [ -n "$TF_BUILD" ]
then
    echo "Set AZURE variable $1=$2"
    echo "##vso[task.setvariable variable=$1]$2"
    echo "##vso[task.setvariable variable=$1]$2"
fi
