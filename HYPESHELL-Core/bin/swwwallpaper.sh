#!/usr/bin/env bash

# Robust swww wallpaper loader for HypeShell
# Usage: swwwallpaper.sh [path_to_image]

WALLPAPER_DIR="$HOME/.config/quickshell/hype-shell/defaults"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/default.jpg"
CONFIG_FILE="$HOME/.config/hype/config/configuration.json"

# Log to a temporary file for debugging
LOG_FILE="/tmp/hypeshell-wallpaper.log"
echo "[$(date)] swwwallpaper.sh started" > "$LOG_FILE"

if ! command -v swww >/dev/null 2>&1; then
    echo "[$(date)] swww not found" >> "$LOG_FILE"
    exit 0
fi

# Ensure swww-daemon is running
if ! swww query >/dev/null 2>&1; then
    echo "[$(date)] Starting swww-daemon..." >> "$LOG_FILE"
    swww-daemon --format xrgb &
    sleep 2
fi

# Function to URL decode
urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

# Determine which image to show
IMG="$DEFAULT_WALLPAPER"

# 1. Check if argument provided
if [[ -n "$1" ]]; then
    IMG="$1"
# 2. Check if saved in configuration.json
elif [[ -f "$CONFIG_FILE" ]]; then
    if command -v jq >/dev/null 2>&1; then
        JQ_WALL=$(jq -r '.appearance.background.path' "$CONFIG_FILE" 2>/dev/null)
        if [[ "$JQ_WALL" != "null" && -n "$JQ_WALL" ]]; then
             IMG="$JQ_WALL"
        fi
    else
        GREP_WALL=$(grep -oP '"path":\s*"\K[^"]+' "$CONFIG_FILE" | head -n1)
        if [[ -n "$GREP_WALL" ]]; then
            IMG="$GREP_WALL"
        fi
    fi
fi

# Strip file:// prefix if present
if [[ "$IMG" == file://* ]]; then
    IMG="${IMG#file://}"
fi

# Decode URL encoding (spaces, etc.)
IMG=$(urldecode "$IMG")

if [[ -f "$IMG" ]]; then
    echo "[$(date)] Loading wallpaper: $IMG" >> "$LOG_FILE"
    swww img "$IMG" --transition-type simple --transition-duration 2
else
    echo "[$(date)] Wallpaper not found: $IMG (falling back to default)" >> "$LOG_FILE"
    IMG="$DEFAULT_WALLPAPER"
    if [[ -f "$IMG" ]]; then
        swww img "$IMG" --transition-type simple --transition-duration 2
    fi
fi
