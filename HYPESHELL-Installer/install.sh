#!/usr/bin/env bash

# =============================================================================
# HYPESHELL INSTALLER - "HYPELAND" EDITION
# Target: Lean Arch Linux Post-Install
# AUR Helper: paru
#
# Product Goal:
#   HypeShell is a lightweight Hyprland desktop shell layer designed to make
#   Arch/Hyprland approachable for Windows users without requiring manual config
#   editing. It provides a pretty shell, centralized settings, future HypeStore
#   modules/gadgets, and GUI-managed system behavior.
#
# Expected USB layout:
#   USB/
#     install.sh
#     config/
#       hypr/
#       quickshell/
#       hype/
#     bin/
# =============================================================================

set -euo pipefail

# =============================================================================
# COLORS & UI
# =============================================================================

export CLR_RESET="\033[0m"
export CLR_HYPE="\033[1;35m"
export CLR_OK="\033[1;32m"
export CLR_ERR="\033[1;31m"
export CLR_INFO="\033[1;34m"
export CLR_WARN="\033[1;33m"

export BUILD_FINGERPRINT="HYPE-20260430-SETTINGS-UPDATER"
mkdir -p "$HOME/.config/hype"
echo "$BUILD_FINGERPRINT" > "$HOME/.config/hype/version"

echo -e "${CLR_INFO}Applying Windows Syntax Fix (CRLF to LF)...${CLR_RESET}"
if [[ -d "$HOME/.config/quickshell/hype-shell" ]]; then
    find "$HOME/.config/quickshell/hype-shell" -type f \( -name "*.qml" -o -name "*.sh" -o -name "*.js" \) -exec sed -i 's/\r$//' {} +
fi

print_banner() {
    clear || true
    echo -e "${CLR_HYPE}"
    echo "   __  __                   _____ __         ____"
    echo "  / / / /_  ______  ___    / ___// /_  ___  / / /"
    echo " / /_/ / / / / __ \/ _ \   \__ \/ __ \/ _ \/ / / "
    echo "/ __  / /_/ / /_/ /  __/  ___/ / / / /  __/ / /  "
    echo "/_/ /_/\__, / .___/\___/  /____/_/ /_/\___/_/_/   "
    echo "      /____/_/                                     "
    echo -e "        --- HYPESHELL / HYPELAND INSTALLER ---"
    echo -e "        Build Fingerprint: ${CLR_OK}${BUILD_FINGERPRINT}${CLR_RESET}\n"
}

# Logs go to stderr so package-filter functions can safely print package names to stdout.
print_status() { echo -e "${CLR_INFO}[STATUS]${CLR_RESET} $1" >&2; }
print_ok()     { echo -e "${CLR_OK}[OK]${CLR_RESET} $1" >&2; }
print_warn()   { echo -e "${CLR_WARN}[WARN]${CLR_RESET} $1" >&2; }
print_err()    { echo -e "${CLR_ERR}[ERR]${CLR_RESET} $1" >&2; }

# =============================================================================
# PATHS
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
BIN_HOME="$HOME/.local/bin"

HYPE_CONFIG="$CONFIG_HOME/hype"
HYPE_DATA="$DATA_HOME/hypeshell"
HYPE_CACHE="$CACHE_HOME/hypeshell"
BACKUP_ROOT="$HOME/.hypeshell-backups"

HYPESHELL_GITHUB_OWNER="${HYPESHELL_GITHUB_OWNER:-acarlton5}"
HYPESHELL_GITHUB_BASE="${HYPESHELL_GITHUB_BASE:-https://github.com/$HYPESHELL_GITHUB_OWNER}"
HYPESHELL_REPO="${HYPESHELL_REPO:-HYPESHELL}"
HYPESHELL_INSTALLER_PATH="${HYPESHELL_INSTALLER_PATH:-HYPESHELL-Installer}"
HYPESHELL_CORE_PATH="${HYPESHELL_CORE_PATH:-HYPESHELL-Core}"
HYPESHELL_STORE_PATH="${HYPESHELL_STORE_PATH:-HYPESHELL-HYPESTORE}"
HYPESHELL_INSTALLER_REPO="${HYPESHELL_INSTALLER_REPO:-$HYPESHELL_REPO}"
HYPESHELL_CORE_REPO="${HYPESHELL_CORE_REPO:-$HYPESHELL_REPO}"
HYPESHELL_STORE_REPO="${HYPESHELL_STORE_REPO:-$HYPESHELL_REPO}"
HYPESHELL_MODULES_REPO="${HYPESHELL_MODULES_REPO:-HYPEMODULE}"
HYPESHELL_GADGETS_REPO="${HYPESHELL_GADGETS_REPO:-HYPEGADGET}"
HYPESHELL_THEMES_REPO="${HYPESHELL_THEMES_REPO:-HYPETHEME}"
HYPESHELL_CORE_BRANCH="${HYPESHELL_CORE_BRANCH:-main}"
HYPESHELL_STORE_BRANCH="${HYPESHELL_STORE_BRANCH:-main}"
HYPESHELL_CORE_REPO_URL="${HYPESHELL_CORE_REPO_URL:-$HYPESHELL_GITHUB_BASE/$HYPESHELL_CORE_REPO.git}"
HYPESHELL_STORE_INDEX_URL="${HYPESHELL_STORE_INDEX_URL:-https://raw.githubusercontent.com/$HYPESHELL_GITHUB_OWNER/$HYPESHELL_STORE_REPO/$HYPESHELL_STORE_BRANCH/$HYPESHELL_STORE_PATH/index.json}"
HYPESHELL_PAYLOAD_DIR="$SCRIPT_DIR"

# =============================================================================
# PACKAGE LISTS
# =============================================================================

BOOTSTRAP_PKGS=(
    git
    base-devel
    fakeroot
    debugedit
    rust
    cargo
)

# System baseline: only what HypeShell needs to boot and operate.
SYSTEM_PACMAN_PKGS=(
    sudo
    archlinux-keyring
    networkmanager
    xdg-user-dirs
    dbus
)

# Audio/session baseline.
AUDIO_PACMAN_PKGS=(
    pipewire
    wireplumber
    pipewire-pulse
    pipewire-alsa
)

# Hyprland and Wayland foundation.
HYPRLAND_PACMAN_PKGS=(
    hyprland
    hypridle
    hyprlock
    hyprpolkitagent
    uwsm
    libnewt
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    wayland
    wayland-protocols
    qt5-wayland
    qt6-wayland
)

# Quickshell/QML shell dependencies.
SHELL_QT_PACMAN_PKGS=(
    qt6-base
    qt6-declarative
    qt6-svg
    qt6-imageformats
    qt6-multimedia
    qt6-positioning
    qt6-sensors
    qt6-5compat
    qt5-quickcontrols2
    qt5-graphicaleffects
)

# Extra deps required when building quickshell-git directly.
QUICKSHELL_PACMAN_DEPS=(
    jemalloc
    vulkan-headers
    cmake
    ninja
    meson
    gcc
    pkgconf
)

QUICKSHELL_AUR_DEPS=(
    cpptrace
)

# Lightweight shell UX essentials.
SHELL_UX_PACMAN_PKGS=(
    kitty
    rofi-wayland
    dunst
    swww
    cliphist
    wl-clipboard
    playerctl
    brightnessctl
    pamixer
)

# QML login for HypeShell/Hyprland systems.
SDDM_PACMAN_PKGS=(
    sddm
    xorg-server
    xorg-xauth
)

# Nice-to-have desktop comfort tools. Not installed by default.
COMFORT_PACMAN_PKGS=(
    bluez
    bluez-utils
    pacman-contrib
    reflector
    dolphin
    file-roller
    ark
    udiskie
    gvfs
    gvfs-mtp
    gvfs-smb
    tumbler
    ffmpegthumbnailer
    pavucontrol
    btop
    fastfetch
    vulkan-tools
    libva-utils
)

# Screenshots/recording.
SCREENSHOT_PACMAN_PKGS=(
    grim
    slurp
    swappy
    wf-recorder
    imagemagick
)

# Theme/UI polish.
THEME_PACMAN_PKGS=(
    matugen
    python-pywal
    nwg-look
    qt5ct
    qt6ct
    kvantum
    papirus-icon-theme
    breeze
    breeze-icons
    bibata-cursor-theme
    ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    otf-font-awesome
)

# Fonts required for HypeShell bar/UI (AUR)
THEME_AUR_PKGS=(
    ttf-gabarito
    ttf-material-symbols-variable-git
    ttf-readex-pro
    ttf-space-grotesk
)

# HypeShell settings/store foundation tools.
HYPESTORE_FOUNDATION_PKGS=(
    jq
    curl
    rsync
)

# Hardware detection and graphics baseline.
HARDWARE_PACMAN_PKGS=(
    pciutils
    usbutils
    mesa
    vulkan-icd-loader
)

# Optional dev/workstation stack.
WORKSTATION_PACMAN_PKGS=(
    nano
    vim
    neovim
    github-cli
    docker
    docker-compose
)

# Do NOT include paru-bin here. paru is bootstrapped separately.
CORE_AUR_PKGS=()

OPTIONAL_AUR_PKGS=()

# =============================================================================
# SAFETY CHECKS
# =============================================================================

require_installed_arch_os() {
    if [[ $EUID -eq 0 ]]; then
        print_err "Do not run this installer as root."
        print_err "Run it as your normal user. The script will use sudo when needed."
        exit 1
    fi

    if [[ -d /run/archiso ]]; then
        print_err "You appear to be running from the Arch ISO/live installer."
        print_err "Boot into the installed Arch OS, log in as your normal user, then run this script."
        exit 1
    fi

    if ! command -v pacman &>/dev/null; then
        print_err "pacman was not found. This installer is intended for Arch Linux."
        exit 1
    fi

    if ! command -v sudo &>/dev/null; then
        print_err "sudo is not installed or unavailable."
        print_err "Install sudo and add your user to wheel before running this script."
        exit 1
    fi

    print_status "Checking sudo access..."
    sudo -v
}

check_usb_layout() {
    print_status "Checking installer USB/source layout..."
    print_status "Installer source path: $SCRIPT_DIR"
    print_status "Core repository fallback: $HYPESHELL_CORE_REPO_URL"

    if [[ ! -d "$SCRIPT_DIR/config" ]]; then
        print_warn "No config folder found beside install.sh."
        print_warn "Expected: $SCRIPT_DIR/config"
    fi

    if [[ ! -d "$SCRIPT_DIR/config/hypr" ]]; then
        print_warn "Missing Hyprland config folder: $SCRIPT_DIR/config/hypr"
    else
        print_ok "Found Hyprland config folder."
    fi

    if [[ ! -d "$SCRIPT_DIR/config/quickshell" ]]; then
        print_warn "Missing Quickshell config folder: $SCRIPT_DIR/config/quickshell"
    else
        print_ok "Found Quickshell config folder."
    fi

    if [[ ! -d "$SCRIPT_DIR/config/hype" ]]; then
        print_warn "Missing HypeShell config folder: $SCRIPT_DIR/config/hype"
    else
        print_ok "Found HypeShell config folder."
    fi

    if [[ ! -d "$SCRIPT_DIR/bin" ]]; then
        print_warn "No bin folder found beside install.sh."
        print_warn "Expected: $SCRIPT_DIR/bin"
    else
        print_ok "Found local bin folder."
    fi

    if [[ ! -w "$HOME" ]]; then
        print_err "Home directory is not writable: $HOME"
        exit 1
    fi

    print_ok "USB/source layout check complete."
}

ensure_hypeshell_payload() {
    if [[ -d "$SCRIPT_DIR/config/hypr" && -d "$SCRIPT_DIR/config/quickshell" && -d "$SCRIPT_DIR/config/hype" ]]; then
        HYPESHELL_PAYLOAD_DIR="$SCRIPT_DIR"
        print_ok "Using bundled HypeShell core payload."
        return 0
    fi

    print_status "Bundled core payload not found. Fetching $HYPESHELL_CORE_REPO..."

    local clone_target="$HYPE_CACHE/repos/$HYPESHELL_CORE_REPO"
    local payload_target
    mkdir -p "$(dirname "$clone_target")"

    if [[ "$clone_target" != "$HYPE_CACHE/repos/"* ]]; then
        print_err "Refusing to prepare core payload outside HypeShell cache."
        exit 1
    fi

    rm -rf "$clone_target"
    git clone --depth 1 --branch "$HYPESHELL_CORE_BRANCH" "$HYPESHELL_CORE_REPO_URL" "$clone_target"

    if [[ -d "$clone_target/$HYPESHELL_CORE_PATH/config/quickshell" && -d "$clone_target/$HYPESHELL_CORE_PATH/config/hype" ]]; then
        payload_target="$clone_target/$HYPESHELL_CORE_PATH"
    else
        payload_target="$clone_target"
    fi

    if [[ ! -d "$payload_target/config/quickshell" || ! -d "$payload_target/config/hype" ]]; then
        print_err "$HYPESHELL_CORE_REPO did not contain the expected HypeShell core payload."
        print_err "Checked: $payload_target"
        exit 1
    fi

    HYPESHELL_PAYLOAD_DIR="$payload_target"
    print_ok "Using HypeShell core payload from $HYPESHELL_PAYLOAD_DIR."
}

# =============================================================================
# HELPERS
# =============================================================================

command_exists() {
    command -v "$1" &>/dev/null
}

pkg_installed() {
    pacman -Q "$1" &>/dev/null
}

pacman_pkg_available() {
    pacman -Si "$1" &>/dev/null
}

aur_pkg_available() {
    paru -Si "$1" &>/dev/null
}

multilib_enabled() {
    grep -Eq '^\[multilib\]' /etc/pacman.conf
}

ensure_user_path() {
    mkdir -p "$BIN_HOME"

    if [[ ":$PATH:" != *":$BIN_HOME:"* ]]; then
        print_warn "$BIN_HOME is not currently in PATH for this shell."
        print_warn "Most login shells will pick it up automatically after reboot/login."
    fi
}

filter_missing_pacman_pkgs() {
    local missing=()

    for pkg in "$@"; do
        if pkg_installed "$pkg"; then
            print_ok "$pkg already installed. Skipping."
        elif ! pacman_pkg_available "$pkg"; then
            print_warn "$pkg was not found in enabled pacman repos. Skipping."
        else
            missing+=("$pkg")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        printf '%s\n' "${missing[@]}"
    fi
}

filter_missing_aur_pkgs() {
    local missing=()

    for pkg in "$@"; do
        if pkg_installed "$pkg"; then
            print_ok "$pkg already installed. Skipping."
        elif ! aur_pkg_available "$pkg"; then
            print_warn "$pkg was not found by paru/AUR. Skipping."
        else
            missing+=("$pkg")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        printf '%s\n' "${missing[@]}"
    fi
}

install_pacman_pkgs() {
    local pkgs=("$@")
    local missing=()

    if (( ${#pkgs[@]} == 0 )); then
        return 0
    fi

    mapfile -t missing < <(filter_missing_pacman_pkgs "${pkgs[@]}")

    if (( ${#missing[@]} == 0 )); then
        print_ok "All requested pacman packages already installed or unavailable."
        return 0
    fi

    print_status "Installing pacman packages: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
}

install_aur_pkgs() {
    local pkgs=("$@")
    local missing=()

    if (( ${#pkgs[@]} == 0 )); then
        return 0
    fi

    if ! command_exists paru; then
        print_err "paru is not installed. Cannot install AUR packages."
        exit 1
    fi

    mapfile -t missing < <(filter_missing_aur_pkgs "${pkgs[@]}")

    if (( ${#missing[@]} == 0 )); then
        print_ok "All requested AUR packages already installed or unavailable."
        return 0
    fi

    print_status "Installing AUR packages: ${missing[*]}"
    paru -S --needed --noconfirm "${missing[@]}"
}

backup_existing_path() {
    local target="$1"

    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_ROOT"

        local base
        base="$(basename "$target")"

        local backup="$BACKUP_ROOT/${base}.backup.$(date +%Y%m%d-%H%M%S)"

        print_warn "Existing $target found."
        print_warn "Backing up to $backup"
        mv "$target" "$backup"
    fi
}

copy_config_dir() {
    local name="$1"
    local source="$HYPESHELL_PAYLOAD_DIR/config/$name"
    local target="$CONFIG_HOME/$name"

    if [[ ! -d "$source" ]]; then
        print_warn "Config folder not found: $source"
        return 0
    fi

    backup_existing_path "$target"

    print_status "Deploying $name config..."
    mkdir -p "$CONFIG_HOME"
    cp -r "$source" "$target"
    if [[ "$name" == "quickshell" ]]; then
        find "$target" -type f -path "*/scripts/*" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    fi
    print_ok "$name config deployed."
}

copy_bin_files() {
    if [[ ! -d "$HYPESHELL_PAYLOAD_DIR/bin" ]]; then
        print_warn "No bin folder found. Skipping local binaries."
        return 0
    fi

    mkdir -p "$BIN_HOME"

    if ! compgen -G "$HYPESHELL_PAYLOAD_DIR/bin/*" > /dev/null; then
        print_warn "bin folder exists but is empty. Skipping local binaries."
        return 0
    fi

    print_status "Deploying local binaries to $BIN_HOME..."
    cp -r "$HYPESHELL_PAYLOAD_DIR/bin/"* "$BIN_HOME/"
    chmod +x "$BIN_HOME"/* 2>/dev/null || true
    print_ok "Local binaries deployed."
}

# =============================================================================
# GPU DETECTION
# =============================================================================

detect_gpu() {
    if ! command_exists lspci; then
        echo "generic"
        return 0
    fi

    if lspci | grep -qi "nvidia"; then
        echo "nvidia"
    elif lspci | grep -Eqi "amd|ati"; then
        echo "amd"
    elif lspci | grep -qi "intel"; then
        echo "intel"
    else
        echo "generic"
    fi
}

install_gpu_drivers() {
    local gpu
    gpu="$(detect_gpu)"

    print_status "Detected GPU: $gpu"

    case "$gpu" in
        nvidia)
            print_warn "NVIDIA detected. Installing NVIDIA stack."
            install_pacman_pkgs \
                nvidia \
                nvidia-utils \
                nvidia-settings \
                egl-wayland \
                libva-nvidia-driver
            ;;
        amd)
            print_status "AMD detected. Installing AMD/Mesa stack."
            if multilib_enabled; then
                install_pacman_pkgs \
                    mesa \
                    vulkan-radeon \
                    xf86-video-amdgpu \
                    libva-mesa-driver \
                    mesa-vdpau \
                    lib32-mesa \
                    lib32-vulkan-radeon
            else
                print_warn "multilib is not enabled. Skipping lib32 AMD packages."
                install_pacman_pkgs \
                    mesa \
                    vulkan-radeon \
                    xf86-video-amdgpu \
                    libva-mesa-driver \
                    mesa-vdpau
            fi
            ;;
        intel)
            print_status "Intel detected. Installing Intel/Mesa stack."
            if multilib_enabled; then
                install_pacman_pkgs \
                    mesa \
                    vulkan-intel \
                    intel-media-driver \
                    libva-intel-driver \
                    lib32-mesa \
                    lib32-vulkan-intel
            else
                print_warn "multilib is not enabled. Skipping lib32 Intel packages."
                install_pacman_pkgs \
                    mesa \
                    vulkan-intel \
                    intel-media-driver \
                    libva-intel-driver
            fi
            ;;
        generic)
            print_warn "No NVIDIA, AMD, or Intel GPU detected. Installing generic Mesa only."
            install_pacman_pkgs mesa vulkan-icd-loader
            ;;
    esac
}

# =============================================================================
# HYPESHELL STATE FOUNDATION
# =============================================================================

create_hypeshell_directories() {
    print_status "Creating HypeShell directory structure..."

    mkdir -p "$HYPE_CONFIG"
    mkdir -p "$HYPE_CONFIG/settings"
    mkdir -p "$HYPE_CONFIG/generated"
    mkdir -p "$HYPE_CONFIG/themes"
    mkdir -p "$HYPE_CONFIG/modules-enabled"
    mkdir -p "$HYPE_CONFIG/gadgets-enabled"

    mkdir -p "$HYPE_DATA"
    mkdir -p "$HYPE_DATA/modules"
    mkdir -p "$HYPE_DATA/gadgets"
    mkdir -p "$HYPE_DATA/themes"
    mkdir -p "$HYPE_DATA/store"
    mkdir -p "$HYPE_DATA/templates"

    mkdir -p "$HYPE_CACHE"
    mkdir -p "$HYPE_CACHE/store"
    mkdir -p "$HYPE_CACHE/wallbash"
    mkdir -p "$HYPE_CACHE/generated"

    print_ok "HypeShell directories ready."
}

write_json_if_missing() {
    local file="$1"
    local content="$2"

    if [[ -f "$file" ]]; then
        print_ok "$(basename "$file") already exists. Skipping."
        return 0
    fi

    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$content" > "$file"
    print_ok "Created $file"
}

create_hypeshell_state_files() {
    print_status "Creating HypeShell state files..."

    write_json_if_missing "$HYPE_CONFIG/settings.json" '{
  "schema": "hypeshell.settings.v1",
  "managedBy": "HypeShell",
  "doctrine": "GUI-managed generated configs; manual edits may be overwritten by HypeShell settings.",
  "firstRunComplete": false,
  "shell": {
    "mode": "standard",
    "animations": true,
    "reducedMotion": false
  },
  "userExperience": {
    "windowsSwitcherFriendly": true,
    "showHints": true,
    "showFirstRunWizard": true
  }
}'

    write_json_if_missing "$HYPE_CONFIG/theme.json" '{
  "schema": "hypeshell.theme.v1",
  "activeTheme": "hype-default",
  "wallbash": {
    "enabled": false,
    "sourceWallpaper": null,
    "autoApplyTo": ["hyprland", "kitty", "rofi", "quickshell"]
  }
}'

    write_json_if_missing "$HYPE_CONFIG/packages.json" '{
  "schema": "hypeshell.packages.v1",
  "registryStrategy": "hypeshell-catalog-plus-added-sources",
  "enabledPackages": {
    "HYPEMODULE": [],
    "HYPEGADGET": ["clock"],
    "HYPETHEME": []
  },
  "sources": [
    {
      "id": "hypeshell-core",
      "name": "HYPESHELL Core",
      "type": "git",
      "url": "'"$HYPESHELL_CORE_REPO_URL"'",
      "verified": true,
      "enabled": true
    },
    {
      "id": "hypeshell-store",
      "name": "HYPESHELL HypeStore",
      "type": "registry",
      "url": "'"$HYPESHELL_STORE_INDEX_URL"'",
      "verified": true,
      "enabled": true
    }
  ]
}'

    write_json_if_missing "$HYPE_CONFIG/keybinds.json" '{
  "schema": "hypeshell.keybinds.v1",
  "managed": true,
  "conflictDetection": true,
  "categories": {
    "system": [],
    "apps": [],
    "windowManagement": [],
    "hypeshell": []
  }
}'

    write_json_if_missing "$HYPE_CONFIG/display.json" '{
  "schema": "hypeshell.display.v1",
  "managed": true,
  "monitors": [],
  "lastDetected": null
}'

    write_json_if_missing "$HYPE_CONFIG/store.json" '{
  "schema": "hypeshell.store.v1",
  "enabled": true,
  "moduleDirectory": "~/.local/share/hypeshell/modules",
  "gadgetDirectory": "~/.local/share/hypeshell/gadgets",
  "verifiedOnlyDefault": true,
  "indexUrl": "'"$HYPESHELL_STORE_INDEX_URL"'"
}'

    print_ok "HypeShell state files ready."
}

write_install_marker() {
    local marker="$HYPE_CONFIG/install-state.json"

    cat > "$marker" <<EOF
{
  "schema": "hypeshell.install.v1",
  "installed": true,
  "installDate": "$(date --iso-8601=seconds)",
  "installerPath": "$SCRIPT_DIR",
  "aurHelper": "paru",
  "sourceLayout": "usb-safe",
  "wm": "hyprland",
  "shell": "quickshell",
  "goal": "lightweight GUI-managed Hyprland shell with future HypeStore modules and gadgets"
}
EOF

    print_ok "Install marker written to $marker."
}

# =============================================================================
# INSTALL STEPS
# =============================================================================

sync_keyring_and_db() {
    print_status "Refreshing Arch keyring and package database..."
    sudo pacman -Sy --needed --noconfirm archlinux-keyring
    sudo pacman -Syu --noconfirm
}

install_bootstrap_deps() {
    print_status "Installing bootstrap/build dependencies..."
    sudo pacman -S --needed --noconfirm "${BOOTSTRAP_PKGS[@]}"
}

bootstrap_paru() {
    if command_exists paru; then
        print_ok "paru already installed. Skipping paru bootstrap."
        return 0
    fi

    print_status "Bootstrapping paru AUR helper..."

    local temp_dir
    temp_dir="$(mktemp -d)"

    git clone https://aur.archlinux.org/paru.git "$temp_dir"

    pushd "$temp_dir" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null

    rm -rf "$temp_dir"

    if command_exists paru; then
        print_ok "paru installed successfully."
    else
        print_err "paru install failed."
        exit 1
    fi
}

install_quickshell_git_exact() {
    if pkg_installed quickshell-git || command_exists quickshell || command_exists qs; then
        print_ok "Quickshell already installed. Skipping quickshell-git."
        return 0
    fi

    print_status "Installing quickshell-git dependencies..."

    install_pacman_pkgs "${QUICKSHELL_PACMAN_DEPS[@]}"
    install_aur_pkgs "${QUICKSHELL_AUR_DEPS[@]}"

    print_status "Installing exact AUR package: quickshell-git"

    local temp_dir
    temp_dir="$(mktemp -d)"

    git clone https://aur.archlinux.org/quickshell-git.git "$temp_dir"

    pushd "$temp_dir" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null

    rm -rf "$temp_dir"

    if command_exists quickshell || command_exists qs || pkg_installed quickshell-git; then
        print_ok "quickshell-git installed successfully."
    else
        print_err "quickshell-git install failed."
        exit 1
    fi
}

install_hypeshell_core() {
    print_status "Installing HypeShell lightweight core..."

    install_pacman_pkgs "${SYSTEM_PACMAN_PKGS[@]}"
    install_pacman_pkgs "${AUDIO_PACMAN_PKGS[@]}"
    install_pacman_pkgs "${HARDWARE_PACMAN_PKGS[@]}"

    install_gpu_drivers

    install_pacman_pkgs "${HYPRLAND_PACMAN_PKGS[@]}"
    install_pacman_pkgs "${SHELL_QT_PACMAN_PKGS[@]}"
    install_quickshell_git_exact

    install_pacman_pkgs "${SHELL_UX_PACMAN_PKGS[@]}"
    install_pacman_pkgs "${HYPESTORE_FOUNDATION_PKGS[@]}"

    install_aur_pkgs "${CORE_AUR_PKGS[@]}"
}

install_optional_desktop_comfort() {
    print_status "Installing optional desktop comfort tools..."
    install_pacman_pkgs "${COMFORT_PACMAN_PKGS[@]}"
}

configure_sddm_login() {
    print_status "Installing SDDM graphical login..."
    install_pacman_pkgs "${SDDM_PACMAN_PKGS[@]}"

    print_status "Configuring HypeShell SDDM theme..."
    local theme_dir="/usr/share/sddm/themes/hypeshell"
    sudo mkdir -p "$theme_dir"

    local login_background="/usr/share/backgrounds/hypeshell-login.jpg"
    local bundled_background="$HYPESHELL_PAYLOAD_DIR/config/quickshell/hype-shell/defaults/default.jpg"

    if [[ -f "$bundled_background" ]]; then
        sudo mkdir -p /usr/share/backgrounds
        sudo cp "$bundled_background" "$login_background"
        sudo cp "$bundled_background" "$theme_dir/background.jpg"
    fi

    sudo tee "$theme_dir/metadata.desktop" >/dev/null <<'EOF'
[SddmGreeterTheme]
Name=HypeShell
Description=QML login theme for HypeShell and Hyprland
Author=HypeShell
Type=sddm-theme
Version=0.1.0
MainScript=Main.qml
ConfigFile=theme.conf
Email=
Theme-Id=hypeshell
Theme-API=2.0
EOF

    # Extract clock settings from config if it exists
    CONFIG_JSON="$HOME/.config/hype/config/configuration.json"
    IS_ANALOG="false"
    IS_ENABLED="true"
    if [[ -f "$CONFIG_JSON" ]] && command -v jq >/dev/null 2>&1; then
        IS_ANALOG=$(jq -r '.appearance.background.clock.isAnalog // "false"' "$CONFIG_JSON")
        IS_ENABLED=$(jq -r '.appearance.background.clock.enabled // "true"' "$CONFIG_JSON")
    fi

    if [[ -f "$login_background" ]]; then
        sudo tee "$theme_dir/theme.conf" >/dev/null <<EOF
[General]
background=$login_background
surface=#090b10
surfaceOverlay=#cc070912
surfaceOverlaySoft=#99090b10
text=#f7f3ff
mutedText=#b9c0d4
accent=#ca9ee6
error=#ff7a90
isAnalog=$IS_ANALOG
isEnabled=$IS_ENABLED
EOF
    else
        sudo tee "$theme_dir/theme.conf" >/dev/null <<EOF
[General]
background=
surface=#090b10
surfaceOverlay=#cc070912
surfaceOverlaySoft=#99090b10
text=#f7f3ff
mutedText=#b9c0d4
accent=#ca9ee6
error=#ff7a90
isAnalog=$IS_ANALOG
isEnabled=$IS_ENABLED
EOF
    fi

    sudo tee "$theme_dir/Main.qml" >/dev/null <<'EOF'
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: config.surface
    property int selectedSession: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    Image {
        id: background
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: config.surfaceOverlay }
            GradientStop { position: 0.55; color: config.surfaceOverlaySoft }
            GradientStop { position: 1.0; color: config.surface }
        }
    }

    // Top Right Status Icons (Mocked)
    Row {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 30
            rightMargin: 40
        }
        spacing: 25

        Text {
            text: "󰤨" // Wifi icon
            color: config.text
            font.pixelSize: 24
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            text: "󰂄" // Battery icon
            color: config.text
            font.pixelSize: 24
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            text: "󰐥" // Power icon
            color: config.text
            font.pixelSize: 24
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    // Center Clock and Date
    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 150
        }
        spacing: 15

        // Digital Mode (Default or when gadget is disabled)
        Column {
            visible: config.isEnabled !== "true" || config.isAnalog !== "true"
            spacing: 5
            Text {
                id: clock
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                color: config.text
                font.pixelSize: 156
                font.bold: true
                font.family: "Outfit, Inter, sans-serif"

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(new Date(), "dddd, dd MMMM")
                color: config.mutedText
                font.pixelSize: 32
                font.family: "Outfit, Inter, sans-serif"
            }
        }

        // Analog Mode (Only if gadget is enabled and set to analog)
        Item {
            visible: config.isEnabled === "true" && config.isAnalog === "true"
            width: 350
            height: 350
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#1a000000"
                border.color: config.accent
                border.width: 1
            }

            // Dial markers (simplified)
            Repeater {
                model: 12
                Rectangle {
                    width: 2
                    height: 10
                    color: config.mutedText
                    x: 175 - width / 2
                    y: 10
                    transformOrigin: Item.Bottom
                    transform: Rotation { origin.x: 1; origin.y: 165; angle: index * 30 }
                }
            }

            // Hands
            Rectangle { // Hour
                id: hourHand
                width: 8; height: 90; radius: 4; color: config.text
                x: 175 - 4; y: 175 - 90
                transformOrigin: Item.Bottom
                rotation: (new Date().getHours() % 12 + new Date().getMinutes() / 60) * 30
            }

            Rectangle { // Minute
                id: minuteHand
                width: 5; height: 130; radius: 3; color: config.accent
                x: 175 - 2.5; y: 175 - 130
                transformOrigin: Item.Bottom
                rotation: new Date().getMinutes() * 6
            }

            Rectangle { // Second
                id: secondHand
                width: 2; height: 140; color: config.error
                x: 175 - 1; y: 175 - 140
                transformOrigin: Item.Bottom
                rotation: new Date().getSeconds() * 6
            }

            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: {
                    const d = new Date();
                    hourHand.rotation = (d.getHours() % 12 + d.getMinutes() / 60) * 30;
                    minuteHand.rotation = d.getMinutes() * 6;
                    secondHand.rotation = d.getSeconds() * 6;
                }
            }
        }
    }

    // Login Container at Bottom Center
    Rectangle {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 100
        }
        width: 380
        height: 220
        radius: 24
        color: "#1a000000" // Transparent black
        border.color: config.accent
        border.width: 1

        // Glassmorphism effect (mocked with opacity/blur)
        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "#22ffffff"
            opacity: 0.1
        }

        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 15

            Rectangle {
                width: parent.width
                height: 50
                radius: 12
                color: "#cc090b10"
                border.color: username.activeFocus ? config.accent : "#33ffffff"
                border.width: 1

                TextInput {
                    id: username
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    verticalAlignment: TextInput.AlignVCenter
                    color: config.text
                    text: userModel.lastUser
                    selectByMouse: true
                    font.pixelSize: 16
                    clip: true
                    Keys.onReturnPressed: password.forceActiveFocus()
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    text: "Username"
                    color: config.mutedText
                    font.pixelSize: 16
                    visible: username.text.length === 0 && !username.activeFocus
                }
            }

            Rectangle {
                width: parent.width
                height: 50
                radius: 12
                color: "#cc090b10"
                border.color: password.activeFocus ? config.accent : "#33ffffff"
                border.width: 1

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    verticalAlignment: TextInput.AlignVCenter
                    color: config.text
                    echoMode: TextInput.Password
                    selectByMouse: true
                    font.pixelSize: 16
                    clip: true
                    Keys.onReturnPressed: sddm.login(username.text, password.text, root.selectedSession)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    text: "Password"
                    color: config.mutedText
                    font.pixelSize: 16
                    visible: password.text.length === 0 && !password.activeFocus
                }
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 12
                color: loginMouse.containsMouse ? config.text : config.accent

                Text {
                    anchors.centerIn: parent
                    text: "Unlock"
                    color: "#090b10"
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.login(username.text, password.text, root.selectedSession)
                }
            }
        }
    }

    Text {
        id: errorText
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 50
        }
        text: ""
        color: config.error
        font.pixelSize: 14
        font.bold: true
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Authentication Failed"
            password.text = ""
            password.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        if (username.text.length > 0) password.forceActiveFocus()
        else username.forceActiveFocus()
    }
}
EOF

    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/hypeshell.conf >/dev/null <<'EOF'
[Theme]
Current=hypeshell

[Users]
RememberLastUser=true
RememberLastSession=true
EOF

    sudo systemctl disable greetd.service 2>/dev/null || true
    sudo systemctl enable sddm.service 2>/dev/null || print_warn "Could not enable SDDM."
    print_ok "SDDM graphical login configured. Reboot to see the HypeShell login theme."
}

configure_default_theme() {
    print_status "Configuring HypeShell default theme..."

    local defaults_dir="$HOME/.config/quickshell/hype-shell/defaults"
    local wallpaper="$defaults_dir/default.jpg"

    if [[ -f "$wallpaper" ]]; then
        print_ok "Default wallpaper found."
        # Ensure swww is ready to load it on next boot via hyprland.conf
    else
        print_warn "Default wallpaper not found at $wallpaper"
    fi

    # Set some basic GTK/Qt environment variables if not set
    # (These usually go in ~/.config/environment.d/ or similar, but for now we'll rely on our configs)
    print_ok "HypeShell default theme foundation set."
}

configure_hyprland_tty_launch() {
    print_status "Configuring Hyprland launch from TTY with uwsm..."

    local profile="$HOME/.bash_profile"
    local start_marker="# >>> HypeShell Hyprland TTY autostart >>>"

    touch "$profile"

    if grep -Fq "$start_marker" "$profile"; then
        print_ok "Hyprland TTY autostart already configured in $profile."
        return 0
    fi

    cat >> "$profile" <<'EOF'

# >>> HypeShell Hyprland TTY autostart >>>
if command -v uwsm >/dev/null 2>&1 && uwsm check may-start >/dev/null 2>&1; then
    exec uwsm start hyprland.desktop
fi
# <<< HypeShell Hyprland TTY autostart <<<
EOF

    print_ok "Hyprland TTY autostart added to $profile."
}

install_optional_screenshot_tools() {
    print_status "Installing optional screenshot/recording tools..."
    install_pacman_pkgs "${SCREENSHOT_PACMAN_PKGS[@]}"
    install_aur_pkgs grimblast-git
}

install_optional_theme_tools() {
    print_status "Installing optional theme tooling..."
    install_pacman_pkgs "${THEME_PACMAN_PKGS[@]}"
    install_aur_pkgs "${THEME_AUR_PKGS[@]}"

    print_status "Updating font cache..."
    fc-cache -fv >/dev/null 2>&1 || true
}

install_optional_workstation_tools() {
    print_status "Installing optional workstation tools..."
    install_pacman_pkgs "${WORKSTATION_PACMAN_PKGS[@]}"
}

deploy_configs() {
    print_status "Deploying HypeShell configurations..."

    mkdir -p "$CONFIG_HOME"

    copy_config_dir "hypr"
    copy_config_dir "quickshell"
    copy_config_dir "hype"
    copy_bin_files

    # Deploy Clock Gadget by default
    print_status "Deploying default gadgets..."
    local gadgets_src="$SCRIPT_DIR/HYPEGADGET-Clock"
    local gadgets_dst="$DATA_HOME/hypeshell/gadgets/clock"

    if [[ -d "$gadgets_src" ]]; then
        mkdir -p "$gadgets_dst"
        cp -r "$gadgets_src/"* "$gadgets_dst/"
        print_ok "Clock gadget deployed."
    else
        print_warn "Clock gadget source not found at $gadgets_src"
    fi
}

enable_system_services() {
    print_status "Enabling system services..."

    sudo systemctl enable --now NetworkManager.service 2>/dev/null || print_warn "Could not enable NetworkManager."
    sudo systemctl enable --now bluetooth.service 2>/dev/null || print_warn "Could not enable bluetooth."

    if command_exists docker; then
        sudo systemctl enable --now docker.service 2>/dev/null || print_warn "Could not enable docker."
    fi

    print_ok "System services checked."
}

enable_user_services() {
    print_status "Enabling user services..."

    systemctl --user daemon-reload 2>/dev/null || true

    systemctl --user enable --now pipewire.service 2>/dev/null || true
    systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
    systemctl --user enable --now wireplumber.service 2>/dev/null || true

    print_ok "User services checked."
}

setup_xdg_dirs() {
    print_status "Creating standard user directories..."
    xdg-user-dirs-update 2>/dev/null || true
    print_ok "User directories checked."
}

setup_docker_group() {
    if ! command_exists docker; then
        return 0
    fi

    if groups "$USER" | grep -qw docker; then
        print_ok "$USER is already in the docker group."
        return 0
    fi

    print_status "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    print_warn "Docker group membership requires logout/reboot before it applies."
}

validate_install() {
    print_status "Validating install..."

    local missing_commands=()

    for cmd in Hyprland kitty paru jq curl; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done

    if ! command_exists quickshell && ! command_exists qs; then
        missing_commands+=("quickshell/qs")
    fi

    if pkg_installed google-chrome && ! command_exists google-chrome-stable; then
        missing_commands+=("google-chrome-stable")
    fi

    if pkg_installed antigravity && ! command_exists antigravity; then
        print_warn "Antigravity package appears installed, but command 'antigravity' was not found."
        print_warn "Check the installed desktop entry or package files with:"
        print_warn "pacman -Ql antigravity"
    fi

    if (( ${#missing_commands[@]} > 0 )); then
        print_warn "Some expected commands were not found:"
        for cmd in "${missing_commands[@]}"; do
            echo "  - $cmd"
        done
    else
        print_ok "Core commands found."
    fi

    if [[ -d "$HYPE_DATA/modules" && -d "$HYPE_DATA/gadgets" ]]; then
        print_ok "HypeStore module/gadget directories exist."
    else
        print_warn "HypeStore module/gadget directories missing."
    fi
}

final_notes() {
    print_ok "HypeShell / Hypeland install completed."

    echo
    print_status "What was installed:"
    echo "  - Hyprland compositor/window manager"
    echo "  - uwsm Hyprland session manager"
    echo "  - SDDM QML graphical login if selected"
    echo "  - Quickshell/QML shell layer"
    echo "  - PipeWire/WirePlumber audio stack"
    echo "  - Optional TTY autostart into Hyprland"
    echo "  - HypeShell settings/state foundation"
    echo "  - HypeStore package directories"
    echo "  - Optional desktop/theme/workstation tools"
    echo
    print_status "Next steps:"
    echo "  1. Reboot."
    echo "  2. If graphical login was enabled, choose Hyprland from SDDM."
    echo "     Manual fallback from TTY: uwsm start hyprland.desktop"
    echo "  3. HypeShell config lives in: $HYPE_CONFIG"
    echo "  4. Future modules live in: $HYPE_DATA/modules"
    echo "  5. Future gadgets live in: $HYPE_DATA/gadgets"
    echo "  6. If Docker was newly enabled for your user, reboot or log out/in first."
    echo
    print_warn "Existing configs were backed up under:"
    echo "  $BACKUP_ROOT"
    echo
    echo -e "${CLR_HYPE}Stay Hyped.${CLR_RESET}"
}

# =============================================================================
# MAIN
# =============================================================================

print_banner
require_installed_arch_os
ensure_user_path
check_usb_layout

sync_keyring_and_db
install_bootstrap_deps
bootstrap_paru

ensure_hypeshell_payload
install_hypeshell_core

# Non-interactive setup: Install everything by default
opt_sddm="Y"
opt_tty_launch="Y"
opt_comfort="Y"
opt_screenshots="Y"
opt_themes="Y"
opt_tools="Y"

if [[ "$opt_sddm" =~ ^[Nn]$ ]]; then
    print_warn "Graphical login skipped."
    configure_hyprland_tty_launch
else
    configure_sddm_login
fi

install_optional_desktop_comfort
install_optional_screenshot_tools
install_optional_theme_tools
install_optional_workstation_tools

setup_xdg_dirs
create_hypeshell_directories
deploy_configs
configure_default_theme
create_hypeshell_state_files
write_install_marker

enable_system_services
enable_user_services
setup_docker_group
validate_install
final_notes
