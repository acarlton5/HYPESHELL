# Hype Shell: The Windows-Parity Roadmap

This document outlines the phased strategy to transform the **Hype Shell** from a collection of configuration files and a modular installer into a fully abstracted, GUI-managed operating environment for Arch Linux.

## User Review Required

> [!IMPORTANT]
> The primary goal is **Zero Manual Configuration**. The user should never have to open a text editor to modify Hyprland or Shell behavior.

> [!NOTE]
> This plan assumes the **DSS-OS** installer (Phase 1) is now the baseline for all development.

## Proposed Implementation Phases

---

### Phase 1: Robust Foundation & Deployment (Baseline)
**Goal**: Guaranteed environment consistency via automated installation.

#### [MODIFY] [install.sh](file:///run/media/morph/DATA1/DSS-OS/install.sh)
- [x] Integrate GPU driver detection.
- [x] Modularize config deployment for Hype/Quickshell/Hyprland.
- [x] Standardize on Pipewire/Wayland stack.

---

### Phase 2: Theme & Asset Abstraction (Settings v1)
**Goal**: Retire manual " dcol" and theme file editing.

#### [NEW] Theme Control Module
- Integrated GUI in Hype Shell to select themes (e.g., Synth Wave, Tokyo Night).
- One-click "Apply" that programmatically updates all child configs (Kitty, Rofi, Hyprland).
- Wallbash integration for automatic color extraction from wallpapers.

---

### Phase 3: System Control Layer (The "Settings App")
**Goal**: Abstracting OS configuration binaries (hyprctl, amixer, etc.).

#### Keybind Manager
- GUI to add/remove/modify Hyprland keybinds.
- Automatic conflict detection and category grouping (System, Apps, Window Mgmt).

#### Display & Input Manager
- Visual monitor layout editor (position, resolution, refresh rate).
- Mouse/Touchpad sensitivity and gesture configuration.

---

### Phase 4: The Hype Store (Module Registry)
**Goal**: Ecosystem scale and user-defined expansion.

#### Market Interface
- Centralized UI to discover and install validated QML modules and gadgets.
- "Verified" badge for DSS-Core modules.

#### Registry Backend
- Secure fetching of remote modules from Git repositories.
- Automatic dependency resolution (checking for required daemons/packages).

---

### Phase 5: DSS-Workstation Integration (Enterprise)
**Goal**: Secure, ephemeral workstations for DSS employees.

#### DSS-Auth Bridge
- Integration with DSS-API to unlock employee-only module categories.
- Automatic bootstrapping of the **DSS-Systems** and **DarkFactory** daemons.

#### Ephemerality Manager
- "State Wipe" tools to clear cached git branches and reset drive space on demand, maintaining the 128GB SSD constraint.

---

## Open Questions

> [!IMPORTANT]
> **Registry Strategy**: Should the Hype Store be a single central repository, or should it support "Added Sources" (like Flathub or AUR)?

> [!CAUTION]
> **File Mutation**: How should the Hype Shell handle manual edits to `.conf` files if the GUI is active? (Suggestion: Overwrite-by-GUI doctrine).

## Verification Plan

### Automated Tests
- Scripted validation of config rewrites (ensuring GUI changes result in valid Hyprland syntax).
- Module installation checks (sandboxing).

### Manual Verification
- Testing the full "Clean Install -> Module Install -> Work" flow on a Framework 13.
- Verifying 128GB capacity management after project swaps.
