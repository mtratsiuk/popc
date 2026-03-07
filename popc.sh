#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

SANDBOX_DIR="$HOME/.local/share/popc"

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
    -t popc:latest .

docker run \
    --rm \
    -it \
    --privileged \
    -v "$(pwd):/workspace:rw" \
    -v "$SANDBOX_DIR:/home/opencode/popc-sandbox:rw" \
    -w /workspace \
    popc:latest \
    "$@"
