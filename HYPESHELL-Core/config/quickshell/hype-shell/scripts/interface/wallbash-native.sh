#!/usr/bin/env bash
# wallbash-native.sh — Native color extraction from wallpaper
# Outputs JSON with colorsDark and colorsLight palettes.
# Uses ImageMagick for color quantization (falls back gracefully).

set -euo pipefail

WALLPAPER_PATH="${1:-}"

if [[ -z "$WALLPAPER_PATH" ]]; then
  echo '{"error": "No wallpaper path provided"}' >&2
  exit 1
fi

# Strip file:// prefix if present
WALLPAPER_PATH="${WALLPAPER_PATH#file://}"

if [[ ! -f "$WALLPAPER_PATH" ]]; then
  echo '{"error": "Wallpaper file not found"}' >&2
  exit 1
fi

# Check for ImageMagick (magick or convert)
if command -v magick >/dev/null 2>&1; then
  IM_CMD="magick"
elif command -v convert >/dev/null 2>&1; then
  IM_CMD="convert"
else
  echo '{"error": "ImageMagick not installed (required for native extraction). Install with: pacman -S imagemagick"}' >&2
  exit 1
fi

# === EXTRACT 8 DOMINANT COLORS VIA QUANTIZATION ===
# Resize image small for speed, quantize to 8 colors, output histogram
COLORS_RAW=$($IM_CMD "$WALLPAPER_PATH" -resize 200x200 -colors 8 -unique-colors txt: 2>/dev/null \
  | grep -oE '#[0-9A-Fa-f]{6}' \
  | head -8)

if [[ -z "$COLORS_RAW" ]]; then
  echo '{"error": "Failed to extract colors from image"}' >&2
  exit 1
fi

# Read into array
mapfile -t COLORS <<< "$COLORS_RAW"

# Pad if fewer than 8 colors found (defensive)
while [[ ${#COLORS[@]} -lt 8 ]]; do
  COLORS+=("${COLORS[-1]:-#808080}")
done

# === HELPER: brightness of hex color (0-255 perceived) ===
luminance() {
  local hex="${1#\#}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  # Rec. 709 luma approximation
  echo $(( (r * 2126 + g * 7152 + b * 722) / 10000 ))
}

# === HELPER: lighten/darken a hex color by percent ===
adjust_brightness() {
  local hex="${1#\#}"
  local pct="$2"  # positive lightens, negative darkens

  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))

  if (( pct > 0 )); then
    r=$(( r + (255 - r) * pct / 100 ))
    g=$(( g + (255 - g) * pct / 100 ))
    b=$(( b + (255 - b) * pct / 100 ))
  else
    local absp=$(( -pct ))
    r=$(( r * (100 - absp) / 100 ))
    g=$(( g * (100 - absp) / 100 ))
    b=$(( b * (100 - absp) / 100 ))
  fi

  (( r > 255 )) && r=255; (( r < 0 )) && r=0
  (( g > 255 )) && g=255; (( g < 0 )) && g=0
  (( b > 255 )) && b=255; (( b < 0 )) && b=0

  printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# === SORT COLORS BY LUMINANCE ===
declare -a SORTED
for c in "${COLORS[@]}"; do
  SORTED+=("$(luminance "$c") $c")
done
mapfile -t SORTED_COLORS < <(printf '%s\n' "${SORTED[@]}" | sort -n)

DARKEST="${SORTED_COLORS[0]##* }"
LIGHTEST="${SORTED_COLORS[-1]##* }"
MID_INDEX=$(( ${#SORTED_COLORS[@]} / 2 ))
MIDTONE="${SORTED_COLORS[$MID_INDEX]##* }"

# Pick a vibrant accent — use the brightest non-extreme color
ACCENT_INDEX=$(( ${#SORTED_COLORS[@]} - 2 ))
ACCENT="${SORTED_COLORS[$ACCENT_INDEX]##* }"

# Pick a primary — second-darkest for richness
PRIMARY="${SORTED_COLORS[1]##* }"

# === BUILD DARK PALETTE ===
DARK_SURFACE=$(adjust_brightness "$DARKEST" -20)
DARK_PRIMARY="$PRIMARY"
DARK_ACCENT="$ACCENT"
DARK_TEXT="$LIGHTEST"
DARK_MUTED=$(adjust_brightness "$LIGHTEST" -40)
DARK_ERROR="#ff7a90"

# === BUILD LIGHT PALETTE ===
LIGHT_SURFACE=$(adjust_brightness "$LIGHTEST" 15)
LIGHT_PRIMARY=$(adjust_brightness "$PRIMARY" -25)
LIGHT_ACCENT=$(adjust_brightness "$ACCENT" -20)
LIGHT_TEXT=$(adjust_brightness "$DARKEST" -30)
LIGHT_MUTED=$(adjust_brightness "$MIDTONE" 10)
LIGHT_ERROR="#c41e3a"

# === EMIT JSON ===
cat <<EOF
{
  "colorsDark": {
    "surface": "$DARK_SURFACE",
    "surfaceOverlay": "${DARK_SURFACE}cc",
    "surfaceOverlaySoft": "${DARK_SURFACE}99",
    "primary": "$DARK_PRIMARY",
    "text": "$DARK_TEXT",
    "mutedText": "$DARK_MUTED",
    "accent": "$DARK_ACCENT",
    "accentSecondary": "$DARK_PRIMARY",
    "error": "$DARK_ERROR"
  },
  "colorsLight": {
    "surface": "$LIGHT_SURFACE",
    "surfaceOverlay": "${LIGHT_SURFACE}cc",
    "surfaceOverlaySoft": "${LIGHT_SURFACE}99",
    "primary": "$LIGHT_PRIMARY",
    "text": "$LIGHT_TEXT",
    "mutedText": "$LIGHT_MUTED",
    "accent": "$LIGHT_ACCENT",
    "accentSecondary": "$LIGHT_PRIMARY",
    "error": "$LIGHT_ERROR"
  }
}
EOF
