#!/usr/bin/env bash

set -e

OPENCODE_PORT=6969
TINYPROXY_PORT=9696
OPENCODE_UID=$(id -u opencode)
TINYPROXY_UID=$(id -u tinyproxy)

iptables -A OUTPUT -m owner --uid-owner "$TINYPROXY_UID" -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner "$OPENCODE_UID" -d 127.0.0.1 -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner "$OPENCODE_UID" -j DROP

su tinyproxy -s /bin/sh -c "tinyproxy -d -c /etc/tinyproxy/tinyproxy.conf" > /dev/null 2>&1 &
TINYPROXY_PID=$!

cleanup() {
    kill $TINYPROXY_PID 2>/dev/null
    wait $TINYPROXY_PID 2>/dev/null
}
trap cleanup EXIT SIGTERM SIGINT

chmod 777 /home/opencode 2>/dev/null || true

exec su opencode -s /bin/sh -c '
    export HOME=/home/opencode
    export HTTP_PROXY="http://127.0.0.1:'"$TINYPROXY_PORT"'"
    export HTTPS_PROXY="http://127.0.0.1:'"$TINYPROXY_PORT"'"
    export NO_PROXY="127.0.0.1:'"$OPENCODE_PORT"'"
    exec opencode --port "'"$OPENCODE_PORT"'" "$@"
' -- "$@"
