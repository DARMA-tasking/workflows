#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <golden-setup-fmt> <repository-setup-fmt>" >&2
    exit 2
fi

golden=$1
candidate=$2

for file in "$golden" "$candidate"; do
    if [[ ! -f "$file" || ! -r "$file" ]]; then
        echo "Error: missing or unreadable setup_fmt.cmake: $file" >&2
        exit 1
    fi
done

if cmp -s -- "$golden" "$candidate"; then
    echo "setup_fmt.cmake matches the golden copy."
else
    echo "Error: setup_fmt.cmake differs from the golden copy." >&2
    diff -u -- "$golden" "$candidate" || true
    echo "Copy cmake/GOLD_setup_fmt.cmake from DARMA-tasking/workflows master to $candidate." >&2
    exit 1
fi
