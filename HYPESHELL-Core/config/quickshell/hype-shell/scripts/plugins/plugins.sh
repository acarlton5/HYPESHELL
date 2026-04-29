#!/usr/bin/env bash
set -euo pipefail

# HypeStore 2.0 Plugin & Theme Engine
# Syncs with the HypeStore Registry (index.json)

REGISTRY_URL="${HYPESHELL_STORE_INDEX_URL:-https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-HYPESTORE/index.json}"
CACHE_DIR="/tmp/hypeshell-store"
DATA_ROOT="$HOME/.local/share/hypeshell"

mkdir -p "$CACHE_DIR" "$DATA_ROOT/modules" "$DATA_ROOT/gadgets" "$DATA_ROOT/themes"

fetch_registry() {
  curl -fsSL -H "Cache-Control: no-cache" "$REGISTRY_URL" -o "$CACHE_DIR/registry.json"
}

get_install_dir() {
  local type="$1"
  case "$type" in
    HYPEGADGET) echo "$DATA_ROOT/gadgets" ;;
    HYPEMODULE) echo "$DATA_ROOT/modules" ;;
    HYPETHEME) echo "$DATA_ROOT/themes" ;;
    *) echo "$DATA_ROOT/plugins" ;;
  esac
}

fetch_all_machine() {
  fetch_registry
  
  # Output Format: ID \t Name \t Version \t Author \t Description \t Requires \t Verified \t Type \t Icon
  jq -r '
    (.hypeModules + .hypeGadgets + .hypeThemes)[] | 
    [
      .id,
      .name,
      .version,
      .author,
      .description,
      (.requires_hype // "none"),
      (.verified // false | tostring),
      .packageType,
      (.icon // (if .packageType == "HYPETHEME" then "palette" elif .packageType == "HYPEGADGET" then "widgets" else "extension" end))
    ] | @tsv
  ' "$CACHE_DIR/registry.json"
}

install_package() {
  local id="$1"
  fetch_registry
  
  local pkg_info
  pkg_info=$(jq -c "(.hypeModules + .hypeGadgets + .hypeThemes)[] | select(.id == \"$id\")" "$CACHE_DIR/registry.json")
  
  if [[ -z "$pkg_info" ]]; then
    echo "Package $id not found in registry."
    exit 1
  fi
  
  local repo=$(echo "$pkg_info" | jq -r '.repo')
  local branch=$(echo "$pkg_info" | jq -r '.branch // "main"')
  local subpath=$(echo "$pkg_info" | jq -r '.path // "."')
  local type=$(echo "$pkg_info" | jq -r '.packageType')
  local dst=$(get_install_dir "$type")/"$id"
  local tmp
  local clone_dir
  
  echo "Installing $id to $dst..."
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  clone_dir="$tmp/repo"

  rm -rf "$dst"
  git clone --depth 1 --branch "$branch" "$repo" "$clone_dir"
  mkdir -p "$dst"
  if [[ -n "$subpath" && "$subpath" != "." ]]; then
    cp -a "$clone_dir/$subpath/." "$dst/"
  else
    cp -a "$clone_dir/." "$dst/"
    rm -rf "$dst/.git"
  fi
  echo "Successfully installed $id."
}

uninstall_package() {
  local id="$1"
  fetch_registry
  
  local type=$(jq -r "(.hypeModules + .hypeGadgets + .hypeThemes)[] | select(.id == \"$id\") | .packageType" "$CACHE_DIR/registry.json")
  local dst=$(get_install_dir "$type")/"$id"
  
  if [[ -d "$dst" ]]; then
    rm -rf "$dst"
    echo "Uninstalled $id."
  else
    echo "$id not found at $dst."
  fi
}

case "${1:-}" in
  fetch)
    fetch_all_machine
    ;;
  install)
    install_package "${2:-}"
    ;;
  uninstall)
    uninstall_package "${2:-}"
    ;;
  *)
    echo "Usage: $0 {fetch|install <id>|uninstall <id>}"
    exit 1
    ;;
esac
