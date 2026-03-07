#!/usr/bin/env bash

set -e

START_PATH=$(pwd)
POPC_SOURCE_PATH=$(realpath "$0")
cd "$(dirname "$POPC_SOURCE_PATH")"

SANDBOX_DIR="$HOME/.local/share/popc"

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
    -t popc:latest .

cd $START_PATH

docker run \
    --rm \
    -it \
    --privileged \
    -v "$(pwd):/workspace:rw" \
    -v "$SANDBOX_DIR:/home/opencode/popc-sandbox:rw" \
    -w /workspace \
    popc:latest \
    "$@"
