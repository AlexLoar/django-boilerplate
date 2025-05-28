#!/bin/bash

function poetry_is_not_installed() {
    if ! command -v poetry &> /dev/null; then
        echo "poetry is not installed. Please go to https://python-poetry.org/docs/#installing-with-the-official-installer."
        return 1
    fi
    return 0
}

poetry_is_not_installed
