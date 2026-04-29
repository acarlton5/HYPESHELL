# HYPESHELL

HypeShell is a Hyprland desktop shell and installer stack for fresh Arch Linux systems.

This repository is the fresh monorepo reset for the project. It contains the installer, the core runtime payload, the HypeStore catalog, bundled gadgets, and theme packages in one place.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-Installer/install.sh)
```

## Repository Layout

```text
HYPESHELL-Installer/    Fresh Arch bootstrap installer.
HYPESHELL-Core/         Hyprland, Quickshell, Hype config, scripts, and bins.
HYPESHELL-HYPESTORE/    HypeStore catalog records.
HYPEGADGET-*/           Installable desktop gadget packages.
HYPETHEME-*/            Installable theme packages.
docs/                   Project notes and package contracts.
scripts/                Local maintenance scripts.
```

## HypeStore

The default catalog URL is:

```text
https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-HYPESTORE/index.json
```

Catalog entries point back to this monorepo and use their package folder as the `path`.

## Included

- Hyprland desktop configuration
- Quickshell-based Hype Shell UI
- HypeStore package discovery and install flow
- Default clock and media player gadgets
- Theme packs for Catppuccin, Decay Green, Edge Runner, Frosted Glass, Graphite Mono, Gruvbox Retro, Material Sakura, Nordic Blue, Rose Pine, Synth Wave, and Tokyo Night

Stay Hyped.
