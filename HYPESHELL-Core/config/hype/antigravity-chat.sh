#!/usr/bin/env bash
set -euo pipefail

ANTIGRAVITY_BIN="${ANTIGRAVITY_BIN:-$(command -v antigravity || true)}"
SETTINGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/Antigravity/User/settings.json"
CODEX_SIDEBAR_URI="${CODEX_SIDEBAR_URI:-antigravity://openai.chatgpt/}"

notify_missing() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Antigravity not found" "Install Antigravity or set ANTIGRAVITY_BIN."
  fi

  printf 'Antigravity not found\n' >&2
  exit 1
}

ensure_bin() {
  if [[ -z "${ANTIGRAVITY_BIN}" || ! -x "${ANTIGRAVITY_BIN}" ]]; then
    notify_missing
  fi
}

open_codex_sidebar() {
  if "${ANTIGRAVITY_BIN}" --open-url "${CODEX_SIDEBAR_URI}" >/dev/null 2>&1; then
    exit 0
  fi
}

open_chat_reuse() {
  open_codex_sidebar

  if "${ANTIGRAVITY_BIN}" chat --reuse-window >/dev/null 2>&1; then
    exit 0
  fi

  if "${ANTIGRAVITY_BIN}" --reuse-window >/dev/null 2>&1; then
    exit 0
  fi

  exec "${ANTIGRAVITY_BIN}"
}

open_chat_new() {
  if "${ANTIGRAVITY_BIN}" --new-window --open-url "${CODEX_SIDEBAR_URI}" >/dev/null 2>&1; then
    exit 0
  fi

  if "${ANTIGRAVITY_BIN}" chat --new-window >/dev/null 2>&1; then
    exit 0
  fi

  exec "${ANTIGRAVITY_BIN}" --new-window
}

open_app_reuse() {
  if "${ANTIGRAVITY_BIN}" --reuse-window >/dev/null 2>&1; then
    exit 0
  fi

  exec "${ANTIGRAVITY_BIN}"
}

open_settings() {
  if [[ -f "${SETTINGS_FILE}" ]]; then
    exec "${ANTIGRAVITY_BIN}" --reuse-window "${SETTINGS_FILE}"
  fi

  exec "${ANTIGRAVITY_BIN}" --reuse-window
}

show_status() {
  local installed=0
  local running=0

  if [[ -n "${ANTIGRAVITY_BIN}" && -x "${ANTIGRAVITY_BIN}" ]]; then
    installed=1
  fi

  if pgrep -af '(^|/)(antigravity)( |$)|/opt/Antigravity/' >/dev/null 2>&1; then
    running=1
  fi

  printf 'installed=%s\n' "${installed}"
  printf 'running=%s\n' "${running}"
  printf 'settings=%s\n' "${SETTINGS_FILE}"
}

case "${1:-open-chat}" in
  open-chat)
    ensure_bin
    open_chat_reuse
    ;;
  open-chat-new)
    ensure_bin
    open_chat_new
    ;;
  open-app)
    ensure_bin
    open_app_reuse
    ;;
  open-settings)
    ensure_bin
    open_settings
    ;;
  status)
    show_status
    ;;
  *)
    printf 'Usage: %s [open-chat|open-chat-new|open-app|open-settings|status]\n' "$0" >&2
    exit 1
    ;;
esac
