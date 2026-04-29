#!/usr/bin/env bash
# launch-dss-panel.sh — Launches the DSS WebEngine panel in a dedicated special workspace.

QML_FILE="$(dirname "$0")/dss-panel.qml"
URL="${1:-about:blank}"

# Load admin token for bypass
TOKEN_FILE="/run/media/morph/DATA/projects/dss-sys/gitea_admin_token.txt"
if [ -f "$TOKEN_FILE" ]; then
    export GITEA_ADMIN_TOKEN=$(cat "$TOKEN_FILE" | tr -d '\n\r')
fi

# Capture the active monitor NOW
ACTIVE_MONITOR=$(hyprctl activeworkspace -j 2>/dev/null \
    | python3 -c "import json,sys; print(json.load(sys.stdin).get('monitor',''))" 2>/dev/null || true)

KILLED_EXTERNALLY=0

on_signal() {
    KILLED_EXTERNALLY=1
    kill "$QML_PID" 2>/dev/null || true
    exit 0
}

on_exit() {
    if [ "$KILLED_EXTERNALLY" = "0" ]; then
        hyprctl dispatch submap reset >/dev/null 2>&1 || true
        hyprctl dispatch togglespecialworkspace dss-panel >/dev/null 2>&1 || true
    fi
    kill "$QML_PID" 2>/dev/null || true
}

trap on_exit EXIT
trap on_signal INT TERM HUP

# Wait for daemon port (3001) to be alive
for i in {1..20}; do
    if curl -s http://localhost:3001 >/dev/null; then
        break
    fi
    sleep 0.2
done

# Launch qml6
qml6 --platform wayland "$QML_FILE" -- "$URL" "$GITEA_ADMIN_TOKEN" &
QML_PID=$!

# Wait for the DSS Panel window to appear
ADDR=""
for i in $(seq 1 27); do
    sleep 0.3
    ADDR=$(hyprctl clients -j 2>/dev/null | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c.get('initialTitle') == 'DSS Systems Panel':
        print(c['address'])
        break
" 2>/dev/null || true)
    [ -n "$ADDR" ] && break
done

if [ -n "$ADDR" ]; then
    hyprctl dispatch movetoworkspacesilent "special:dss-panel,address:${ADDR}" 2>/dev/null || true
    [ -n "$ACTIVE_MONITOR" ] && hyprctl dispatch focusmonitor "$ACTIVE_MONITOR" 2>/dev/null || true
    hyprctl dispatch togglespecialworkspace dss-panel 2>/dev/null || true
fi

while kill -0 "$QML_PID" 2>/dev/null; do
    sleep 1
done
