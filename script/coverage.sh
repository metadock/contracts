#!/bin/bash

# generates lcov.info
forge coverage \
    --report lcov \

if ! command -v lcov &>/dev/null; then
    echo "lcov is not installed. Installing..."
    sudo apt-get install lcov
fi

lcov --version

EXCLUDE="*test* *node_modules*"
lcov \
    --rc lcov_branch_coverage=1 \
    --remove lcov.info $EXCLUDE \
    --output-file formatted-lcov.info \
    --ignore-errors inconsistent \

if [ "$CI" != "true" ]; then
    genhtml formatted-lcov.info \
        --rc lcov_branch_coverage=1 \
        --output-directory coverage \
        --ignore-errors deprecated,inconsistent,corrupt
    open coverage/index.html
fi