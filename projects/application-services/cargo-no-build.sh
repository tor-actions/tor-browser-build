#!/bin/bash

if [[ "$1" == "build" ]]; then
    echo "cargo build is disabled."
    exit 0
else
    command cargo "$@"
fi
