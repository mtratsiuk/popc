#!/usr/bin/env bash

set -e

OPENCODE_PORT=6969
TINYPROXY_PORT=9696
AGENT_UID=$(id -u agent)
TINYPROXY_UID=$(id -u tinyproxy)

iptables -A OUTPUT -m owner --uid-owner "$TINYPROXY_UID" -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner "$AGENT_UID" -d 127.0.0.1 -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner "$AGENT_UID" -j DROP

su tinyproxy -s /bin/sh -c "tinyproxy -d -c /etc/tinyproxy/tinyproxy.conf" > /dev/null 2>&1 &
TINYPROXY_PID=$!

cleanup() {
    kill $TINYPROXY_PID 2>/dev/null
    wait $TINYPROXY_PID 2>/dev/null
}
trap cleanup EXIT SIGTERM SIGINT

case "${AGENT:-opencode}" in
  opencode)
    chown agent:$(id -g agent) /home/opencode 2>/dev/null || true
    exec su agent -s /bin/sh -c '
        export HOME=/home/opencode
        export HTTP_PROXY="http://127.0.0.1:'"$TINYPROXY_PORT"'"
        export HTTPS_PROXY="http://127.0.0.1:'"$TINYPROXY_PORT"'"
        export NO_PROXY="127.0.0.1:'"$OPENCODE_PORT"'"
        chmod 740 /home/opencode 2>/dev/null || true
        exec opencode --port "'"$OPENCODE_PORT"'" "$@"
    ' -- "$@"
    ;;
  pi)
    chown agent:$(id -g agent) /home/agent/.pi/agent 2>/dev/null || true
    exec su agent -s /bin/sh -c '
        export HTTP_PROXY="http://127.0.0.1:'"$TINYPROXY_PORT"'"
        export HTTPS_PROXY="http://127.0.0.1:'"$TINYPROXY_PORT"'"
        export NO_PROXY="127.0.0.1"
        chmod 740 /home/agent/.pi/agent 2>/dev/null || true
        exec pi --provider cloudflare-ai-gateway "$@"
    ' -- "$@"
    ;;
  *)
    echo "Unknown value: $AGENT"
    exit 1
    ;;
esac
