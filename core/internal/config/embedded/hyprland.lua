-- Hyprland Configuration

-- https://wiki.hypr.land/Configuring/

-- MONITOR CONFIG
hl.monitor({
    output = "",
    disabled = false,
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

-- STARTUP APPS
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("systemctl --user start hype.service || hype run")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)

-- INPUT CONFIG
hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = true,
    },
})

-- GENERAL LAYOUT
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        layout = "dwindle",
    },
})

-- DECORATION
hl.config({
    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 5,
            offset = "0 5",
            color = "rgba(00000070)",
        },
    },
})

-- ANIMATIONS
hl.config({
    animations = {
        enabled = true,
    },
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 3,
    bezier = "default",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 3,
    bezier = "default",
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    bezier = "default",
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 4,
    bezier = "default",
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3,
    bezier = "default",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 3,
    bezier = "default",
})

-- LAYOUTS
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        mfact = 0.5,
    },
})

-- MISC
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

-- Keep errors queryable without covering the recovery desktop.
hl.config({
    debug = {
        suppress_errors = true,
    },
})

-- WINDOW RULES
hl.window_rule({
    match = {
        class = "^(org\\.wezfurlong\\.wezterm)$",
    },
    tile = 1,
})
hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.)",
    },
    rounding = 12,
})
hl.window_rule({
    match = {
        class = "^(gnome-control-center)$",
    },
    tile = 1,
})
hl.window_rule({
    match = {
        class = "^(pavucontrol)$",
    },
    tile = 1,
})
hl.window_rule({
    match = {
        class = "^(nm-connection-editor)$",
    },
    tile = 1,
})
hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.Calculator)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(gnome-calculator)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(galculator)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(blueman-manager)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.Nautilus)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(xdg-desktop-portal)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(notificationtoasts)$",
    },
    no_initial_focus = 1,
})
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(notificationtoasts)$",
    },
    pin = 1,
})
hl.window_rule({
    match = {
        class = "^(firefox)$",
        title = "^(Picture-in-Picture)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(zoom)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(swayimg)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(swayimg)$",
    },
    center = 1,
})
hl.window_rule({
    match = {
        class = "^(swayimg)$",
    },
    size = "900 700",
})
hl.window_rule({
    match = {
        class = "^(mpv)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(mpv)$",
    },
    center = 1,
})
hl.window_rule({
    match = {
        class = "^(mpv)$",
    },
    size = "1100 700",
})
hl.window_rule({
    match = {
        class = "^(hypeshell-update)$",
    },
    float = 1,
})
hl.window_rule({
    match = {
        class = "^(hypeshell-update)$",
    },
    center = 1,
})
hl.window_rule({
    match = {
        class = "^(hypeshell-update)$",
    },
    size = "900 620",
})

-- LAYER RULES
hl.layer_rule({
    match = {
        namespace = "^(quickshell)$",
    },
    no_anim = 1,
})
hl.layer_rule({
    match = {
        namespace = "^hype:.*",
    },
    no_anim = 1,
})

-- SOURCE FILES
require("hype.colors")
require("hype.outputs")
require("hype.layout")
require("hype.cursor")
require("hype.binds")
require("hype.windowrules")
require("hype.hardware")
