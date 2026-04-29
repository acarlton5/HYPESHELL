# HYPESHELL Repository Layout

HypeShell now lives in one monorepo: `acarlton5/HYPESHELL`.

| Folder | Purpose |
| --- | --- |
| `HYPESHELL-Installer` | Tiny bootstrap installer for fresh Arch Linux installs. |
| `HYPESHELL-Core` | Core Hyprland, Quickshell, Hype config, scripts, and local binaries. |
| `HYPESHELL-HYPESTORE` | Catalog records for all installable packages. |
| `HYPEGADGET-Clock` | Actual installable clock gadget package. |
| `HYPEGADGET-MediaPlayer` | Actual installable media player gadget package. |

## Package Types

Package types are not repo names by themselves. They are catalog vocabulary:

- `HYPEMODULE`: shell package installed into `~/.config/hype/modules/<id>`.
- `HYPEGADGET`: desktop gadget installed into `~/.config/hype/gadgets/<id>`.
- `HYPETHEME`: theme pack installed by future theme-store support.

Bundled packages live as top-level folders. External packages may still use their own repositories later.

## Install Flow

```text
Fresh Arch
  -> HYPESHELL-Installer/install.sh
  -> pacman/paru dependencies
  -> clone acarlton5/HYPESHELL
  -> use HYPESHELL-Core as the payload
  -> deploy HYPESHELL-Core/config/hypr, config/quickshell, config/hype, bin
  -> HypeShell settings reads HYPESHELL-HYPESTORE/index.json
  -> packages install from the repo URL and path declared in each catalog record
```

## External Developer Flow

1. Developer creates a package repo named for the actual package.
2. Developer adds a `manifest.json`.
3. Developer opens a PR to `HYPESHELL-HYPESTORE/index.json`.
4. Catalog maintainers review the record.
5. HypeShell users can discover and install the package.

The installer can run as soon as the monorepo is pushed.
