# HYPESHELL-Installer

Bootstrap installer for fresh Arch Linux systems.

### 🚀 Build Status
**Current Fingerprint:** `HYPE-20260426-0141-ROLLBACK`  
**Last Update:** Rolled back Bar logic to a stable state.

This folder is intentionally small. It installs the base Hyprland/Quickshell stack, then fetches the runtime payload from `HYPESHELL-Core` in the `acarlton5/HYPESHELL` monorepo.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-Installer/install.sh)
```

## Repository Environment Overrides

```bash
HYPESHELL_GITHUB_OWNER=acarlton5
HYPESHELL_REPO=HYPESHELL
HYPESHELL_CORE_PATH=HYPESHELL-Core
HYPESHELL_STORE_PATH=HYPESHELL-HYPESTORE
HYPESHELL_CORE_BRANCH=main
HYPESHELL_STORE_BRANCH=main
```

The installer also supports USB/offline mode. If `config/` is present beside `install.sh`, it uses that local payload instead of cloning the monorepo.
