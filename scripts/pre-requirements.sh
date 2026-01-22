#!/bin/bash

function check_uv_installed() {
    if ! command -v uv &> /dev/null; then
        echo "uv is not installed. Please follow https://docs.astral.sh/uv/getting-started/installation/."
        exit 1
    fi
}

check_uv_installed
