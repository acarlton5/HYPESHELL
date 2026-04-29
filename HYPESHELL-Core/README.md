# HYPESHELL-Core

Core HypeShell runtime payload inside the `acarlton5/HYPESHELL` monorepo.

This repo owns the files that get deployed to a fresh Arch install:

- `config/hypr` -> `~/.config/hypr`
- `config/quickshell` -> `~/.config/quickshell`
- `config/hype` -> `~/.config/hype`
- `bin` -> `~/.local/bin`

`HYPESHELL-Installer` clones this repo when it does not have a bundled local payload.

## Store Source

The default store source is:

```text
https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-HYPESTORE/index.json
```
