#!/usr/bin/env bash
set -Eeuo pipefail

MODULES_ROOT="$HOME/.config/hype/modules"
REGISTRY="$MODULES_ROOT/modules.json"

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
    printf '%s\n' "$MODULES_ROOT/$fallback_id"
  fi
}

emit_module_json() {
  local module_json="$1"
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
        name: ($id // "Unnamed Module"),
        version: "",
        author: "",
        description: "manifest.json not found",
        enabledKey: "",
        type: ($type // "shell-module"),
        path: $path,
        manifestPath: ($path + "/manifest.json"),
        settings: []
      }'
    return
  fi

  jq -nc \
    --argjson module "$module_json" \
    --arg defaultId "$default_id" \
    --arg defaultType "$default_type" \
    --arg path "$path" \
    --arg manifest "$manifest" \
    --slurpfile mf "$manifest" '
      ($mf[0] // {}) as $m |
      {
        id: ($m.id // $module.id // $defaultId // ""),
        name: ($m.name // $module.id // $defaultId // "Unnamed Module"),
        version: ($m.version // ""),
        author: ($m.author // ""),
        description: ($m.description // ""),
        enabledKey: ($m.enabledKey // $module.enabledKey // ""),
        settingsQml: ($m.settingsQml // ""),
        type: ($module.type // $m.type // $defaultType // "shell-module"),
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

# 1) Explicit registry entries.
if [[ -f "$REGISTRY" ]]; then
  while IFS= read -r module; do
    id="$(jq -r '.id // empty' <<<"$module")"
    [[ -n "$id" ]] || continue

    type="$(jq -r '.type // "shell-module"' <<<"$module")"
    raw_path="$(jq -r '.path // empty' <<<"$module")"
    path="$(normalize_path "$raw_path" "$id")"

    emit_module_json "$module" "$id" "$type" "$path" >> "$TMP_OUTPUT"
    SEEN_IDS["$id"]=1
  done < <(jq -c '(.modules // []) | .[]' "$REGISTRY")
fi

# 2) Auto-discover drop-in module folders.
shopt -s nullglob
for manifest in "$MODULES_ROOT"/*/manifest.json; do
  path="$(dirname "$manifest")"
  dir_id="$(basename "$path")"
  module_id="$(jq -r '.id // empty' "$manifest" 2>/dev/null || true)"
  [[ -n "$module_id" ]] || module_id="$dir_id"

  if [[ -n "${SEEN_IDS[$module_id]:-}" ]]; then
    continue
  fi

  emit_module_json '{}' "$module_id" "shell-module" "$path" >> "$TMP_OUTPUT"
  SEEN_IDS["$module_id"]=1
done
shopt -u nullglob

jq -s '.' "$TMP_OUTPUT"
