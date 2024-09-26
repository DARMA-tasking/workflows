#!/usr/bin/env bash

# Docker image cleaning or optimizations

OS=$(cat /etc/os-release | grep -E "^NAME=*" | cut -d = -f 2 | tr -d '"')
OS_VERSION=$(cat /etc/os-release | grep -E "^VERSION_ID=*" | cut -d = -f 2 | tr -d '"')

echo "Cleaning image..."

if [ "$OS" == "Ubuntu" ]; then
    rm -rf /var/lib/apt/lists/*
else
    echo "Error. Please implement the cleanup instructions for OS=$OS."
fi