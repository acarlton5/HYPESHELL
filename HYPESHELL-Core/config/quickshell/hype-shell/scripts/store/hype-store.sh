#!/usr/bin/env bash
set -Eeuo pipefail

STORE_ROOT="$HOME/.config/hype/store"
SOURCES_FILE="$STORE_ROOT/sources.json"
MODULES_ROOT="$HOME/.config/hype/modules"
GADGETS_ROOT="$HOME/.config/hype/gadgets"
THEMES_ROOT="$HOME/.config/hype/themes"

usage() {
  cat >&2 <<'EOF'
Usage:
  hype-store.sh list HYPEMODULE|HYPEGADGET|HYPETHEME
  hype-store.sh install HYPEMODULE|HYPEGADGET|HYPETHEME <id>
  hype-store.sh uninstall HYPEMODULE|HYPEGADGET|HYPETHEME <id>
EOF
}

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

safe_id() {
  local id="${1:-}"
  if [[ ! "$id" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Invalid package id: $id" >&2
    exit 1
  fi
  printf '%s\n' "$id"
}

kind_key() {
  local raw="${1:-}"
  case "${raw^^}" in
    HYPEMODULE) printf '%s\n' "HYPEMODULE" ;;
    HYPEGADGET) printf '%s\n' "HYPEGADGET" ;;
    HYPETHEME) printf '%s\n' "HYPETHEME" ;;
    *) echo "Package type must be HYPEMODULE, HYPEGADGET, or HYPETHEME." >&2; exit 1 ;;
  esac
}

kind_root() {
  case "$(kind_key "$1")" in
    HYPEMODULE) printf '%s\n' "$MODULES_ROOT" ;;
    HYPEGADGET) printf '%s\n' "$GADGETS_ROOT" ;;
    HYPETHEME) printf '%s\n' "$THEMES_ROOT" ;;
  esac
}

ensure_layout() {
  mkdir -p "$STORE_ROOT" "$MODULES_ROOT" "$GADGETS_ROOT" "$THEMES_ROOT"
  if [[ ! -f "$SOURCES_FILE" ]]; then
    cat > "$SOURCES_FILE" <<'EOF'
{
  "sources": [
    {
      "id": "official",
      "name": "HYPESHELL HypeStore",
      "url": "https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-HYPESTORE/index.json"
    }
  ]
}
EOF
  fi
}

fetch_source() {
  local url="$1"

  if [[ "$url" == file://* ]]; then
    cat "${url#file://}"
  elif [[ -f "$url" ]]; then
    cat "$url"
  else
    need_tool curl
    curl -fsSL "$url"
  fi
}

combined_index() {
  ensure_layout
  need_tool jq

  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN

  jq -c '.sources // [] | .[]' "$SOURCES_FILE" | while IFS= read -r source; do
    local source_id source_name source_url
    source_id="$(jq -r '.id // "source"' <<<"$source")"
    source_name="$(jq -r '.name // .id // "Source"' <<<"$source")"
    source_url="$(jq -r '.url // empty' <<<"$source")"
    [[ -n "$source_url" ]] || continue

    if payload="$(fetch_source "$source_url" 2>/dev/null)"; then
      jq -c \
        --arg sourceId "$source_id" \
        --arg sourceName "$source_name" \
        '
          [
            ((.hypeModules // []) | .[] | . + {packageType: "HYPEMODULE", sourceId: $sourceId, sourceName: $sourceName}),
            ((.hypeGadgets // []) | .[] | . + {packageType: "HYPEGADGET", sourceId: $sourceId, sourceName: $sourceName}),
            ((.hypeThemes // []) | .[] | . + {packageType: "HYPETHEME", sourceId: $sourceId, sourceName: $sourceName})
          ] | .[]
        ' <<<"$payload" >> "$tmp"
    fi
  done

  jq -s '.' "$tmp"
}

list_kind() {
  local package_type root
  package_type="$(kind_key "$1")"
  root="$(kind_root "$package_type")"

  combined_index | jq -c \
    --arg packageType "$package_type" \
    '
      map(select(.packageType == $packageType))
      | map({
          id: (.id // ""),
          name: (.name // .id // "Unnamed"),
          version: (.version // ""),
          author: (.author // ""),
          description: (.description // ""),
          sourceId: (.sourceId // ""),
          sourceName: (.sourceName // ""),
          packageType: (.packageType // ""),
          repo: (.repo // ""),
          branch: (.branch // "main"),
          path: (.path // "")
        })
      | map(select(.id != ""))
      | .[]
    ' | while IFS= read -r entry; do
      local package_id installed
      package_id="$(jq -r '.id' <<<"$entry")"
      installed=false
      [[ -d "$root/$package_id" ]] && installed=true
      jq -c --argjson installed "$installed" '. + {installed: $installed}' <<<"$entry"
    done | jq -s '.'
}

entry_json() {
  local package_type="$1"
  local id="$2"
  combined_index | jq -e --arg packageType "$package_type" --arg id "$id" \
    'first(.[] | select(.packageType == $packageType and .id == $id))'
}

install_entry() {
  local package_type id root entry repo branch subpath target tmp clone_dir
  package_type="$(kind_key "$1")"
  id="$(safe_id "$2")"
  root="$(kind_root "$package_type")"
  entry="$(entry_json "$package_type" "$id")"
  repo="$(jq -r '.repo // empty' <<<"$entry")"
  branch="$(jq -r '.branch // "main"' <<<"$entry")"
  subpath="$(jq -r '.path // empty' <<<"$entry")"
  target="$root/$id"

  [[ -n "$repo" ]] || { echo "Store entry $id does not declare a repo." >&2; exit 1; }
  need_tool git
  mkdir -p "$root"

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  clone_dir="$tmp/repo"

  git clone --depth 1 --branch "$branch" "$repo" "$clone_dir" >/dev/null
  rm -rf "$target"
  mkdir -p "$target"

  if [[ -n "$subpath" && "$subpath" != "." ]]; then
    cp -a "$clone_dir/$subpath/." "$target/"
  else
    cp -a "$clone_dir/." "$target/"
    rm -rf "$target/.git"
  fi

  [[ -f "$target/manifest.json" || "$package_type" == "HYPETHEME" ]] || {
    echo "Installed package has no manifest.json: $target" >&2
    exit 1
  }

  echo "installed $package_type/$id"
}

uninstall_entry() {
  local package_type id root target
  package_type="$(kind_key "$1")"
  id="$(safe_id "$2")"
  root="$(kind_root "$package_type")"
  target="$root/$id"

  if [[ "$target" != "$root/"* ]]; then
    echo "Refusing to remove outside $root" >&2
    exit 1
  fi

  rm -rf "$target"
  echo "uninstalled $package_type/$id"
}

action="${1:-}"
kind="${2:-}"
id="${3:-}"

case "$action" in
  list)
    [[ -n "$kind" ]] || { usage; exit 1; }
    list_kind "$kind"
    ;;
  install)
    [[ -n "$kind" && -n "$id" ]] || { usage; exit 1; }
    install_entry "$kind" "$id"
    ;;
  uninstall|remove)
    [[ -n "$kind" && -n "$id" ]] || { usage; exit 1; }
    uninstall_entry "$kind" "$id"
    ;;
  *)
    usage
    exit 1
    ;;
esac
