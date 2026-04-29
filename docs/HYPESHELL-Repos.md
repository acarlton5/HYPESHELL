# HYPESHELL Repository Layout

HypeShell is currently published as one monorepo:

```text
acarlton5/HYPESHELL
```

The old split-repository layout was retired during the 2026 reset. Package records now point to the monorepo and use `path` to identify the installable subfolder.

## Top-Level Folders

| Folder | Purpose |
| --- | --- |
| `HYPESHELL-Installer` | Bootstrap installer for fresh Arch Linux installs. |
| `HYPESHELL-Core` | Core Hyprland, Quickshell, Hype config, scripts, and local binaries. |
| `HYPESHELL-HYPESTORE` | Catalog of `HYPEMODULE`, `HYPEGADGET`, and `HYPETHEME` packages. |
| `HYPEGADGET-*` | Installable gadget packages. |
| `HYPETHEME-*` | Installable theme packages. |

## Install Flow

```text
Fresh Arch
  -> HYPESHELL-Installer/install.sh
  -> pacman/paru dependencies
  -> clone acarlton5/HYPESHELL
  -> use HYPESHELL-Core as the runtime payload
  -> deploy config/hypr, config/quickshell, config/hype, bin
  -> HypeStore reads HYPESHELL-HYPESTORE/index.json
  -> packages install from the subfolder path declared in each catalog record
```

## Package Types

- `HYPEMODULE`: shell package installed into `~/.config/hype/modules/<id>`.
- `HYPEGADGET`: desktop gadget installed into `~/.config/hype/gadgets/<id>`.
- `HYPETHEME`: theme pack installed into `~/.config/hype/themes/<id>`.

External packages can still live in their own repos later. For bundled packages, keep the source in this monorepo and set catalog `repo` to `https://github.com/acarlton5/HYPESHELL.git` with `path` set to the package folder.
