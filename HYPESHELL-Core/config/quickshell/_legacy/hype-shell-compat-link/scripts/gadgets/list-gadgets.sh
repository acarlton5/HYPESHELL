#!/usr/bin/env bash
set -Eeuo pipefail

GADGETS_ROOT="$HOME/.config/hype/gadgets"
REGISTRY="$GADGETS_ROOT/gadgets.json"
LEGACY_REGISTRY="$GADGETS_ROOT/modules.json"

if [[ ! -f "$REGISTRY" && -f "$LEGACY_REGISTRY" ]]; then
  REGISTRY="$LEGACY_REGISTRY"
fi

if ! command -v jq >/dev/null 2>&1; then
  echo '[]'
  exit 0
fi

normalize_path() {
  local raw="$1"
  local fallback_id="$2"

  if [[ "$raw" == "~/"* ]]; then
    printf '%s\n' "$HOME/${raw#"~/"}"
  elif [[ -n "$raw" ]]; then
    printf '%s\n' "$raw"
  else
    printf '%s\n' "$GADGETS_ROOT/$fallback_id"
  fi
}

emit_gadget_json() {
  local gadget_json="$1"
  local default_id="$2"
  local default_type="$3"
  local path="$4"
  local manifest="$path/manifest.json"

  if [[ ! -f "$manifest" ]]; then
    jq -nc \
      --arg id "$default_id" \
      --arg type "$default_type" \
      --arg path "$path" \
      '{
        id: ($id // ""),
        name: ($id // "Unnamed Gadget"),
        version: "",
        author: "",
        description: "manifest.json not found",
        enabledKey: "",
        type: ($type // "desktop-gadget"),
        path: $path,
        manifestPath: ($path + "/manifest.json"),
        settings: []
      }'
    return
  fi

  jq -nc \
    --argjson gadget "$gadget_json" \
    --arg defaultId "$default_id" \
    --arg defaultType "$default_type" \
    --arg path "$path" \
    --arg manifest "$manifest" \
    --slurpfile mf "$manifest" '
      ($mf[0] // {}) as $m |
      {
        id: ($m.id // $gadget.id // $defaultId // ""),
        name: ($m.name // $gadget.id // $defaultId // "Unnamed Gadget"),
        version: ($m.version // ""),
        author: ($m.author // ""),
        description: ($m.description // ""),
        enabledKey: ($m.enabledKey // $gadget.enabledKey // ""),
        settingsQml: ($m.settingsQml // ""),
        type: ($gadget.type // $m.type // $defaultType // "desktop-gadget"),
        path: $path,
        manifestPath: $manifest,
        settings: (
          ($m.settings // [])
          | map({
              key: (.key // .prefField // ""),
              type: ((.type // "string") | ascii_downcase),
              label: (.label // .title // .key // ""),
              description: (.description // ""),
              min: .min,
              max: .max,
              step: .step,
              default: .default,
              options: (.options // [])
          })
          | map(select(.key != ""))
        )
      }
    '
}

declare -A SEEN_IDS
TMP_OUTPUT="$(mktemp)"
trap 'rm -f "$TMP_OUTPUT"' EXIT

# 1) First load explicit registry entries (if registry exists)
if [[ -f "$REGISTRY" ]]; then
  while IFS= read -r gadget; do
    id="$(jq -r '.id // empty' <<<"$gadget")"
    [[ -n "$id" ]] || continue

    type="$(jq -r '.type // "desktop-gadget"' <<<"$gadget")"
    raw_path="$(jq -r '.path // empty' <<<"$gadget")"
    path="$(normalize_path "$raw_path" "$id")"

    emit_gadget_json "$gadget" "$id" "$type" "$path" >> "$TMP_OUTPUT"
    SEEN_IDS["$id"]=1
  done < <(jq -c '(.gadgets // .modules // []) | .[]' "$REGISTRY")
fi

# 2) Auto-discover drop-in gadget folders with manifest.json
shopt -s nullglob
for manifest in "$GADGETS_ROOT"/*/manifest.json; do
  path="$(dirname "$manifest")"
  dir_id="$(basename "$path")"
  gadget_id="$(jq -r '.id // empty' "$manifest" 2>/dev/null || true)"
  [[ -n "$gadget_id" ]] || gadget_id="$dir_id"

  if [[ -n "${SEEN_IDS[$gadget_id]:-}" ]]; then
    continue
  fi

  emit_gadget_json '{}' "$gadget_id" "desktop-gadget" "$path" >> "$TMP_OUTPUT"
  SEEN_IDS["$gadget_id"]=1
done
shopt -u nullglob

jq -s '.' "$TMP_OUTPUT"
