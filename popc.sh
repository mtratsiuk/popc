#!/usr/bin/env bash

set -e

START_PATH=$(pwd)
POPC_SOURCE_PATH=$(realpath "$0")
cd "$(dirname "$POPC_SOURCE_PATH")"

SANDBOX_DIR_OPENCODE="$HOME/.local/share/popc"
SANDBOX_DIR_PI="$HOME/.local/share/ppi"

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
    -t popc:latest .

cd $START_PATH

docker run \
    --rm \
    -it \
    --cap-add NET_ADMIN \
    -v "/usr/local/go:/usr/local/go:ro" \
    -v "$HOME/go/bin:/lib/go/bin:ro" \
    -v "$(go env GOCACHE):/lib/go/cache:rw" \
    -v "$(go env GOMODCACHE):/lib/go/modcache:rw" \
    -v "$(pwd):/workspace:rw" \
    -v "$SANDBOX_DIR_OPENCODE:/home/opencode:rw" \
    -v "$SANDBOX_DIR_PI:/home/agent/.pi/agent:rw" \
    -w /workspace \
    --env GOCACHE=/lib/go/cache \
    --env GOMODCACHE=/lib/go/modcache \
    --env GOPATH=/lib/go \
    --env AGENT=$AGENT \
    popc:latest \
    "$@"
