hl.config({
    bind = {
        "SUPER ALT, SPACE, exec, $HOME/DevBox/quickshell_menu/toggle.sh"
    },
    bindl = {
        ", switch:on:Apple SMC power/lid events, exec, hype ipc call lock lock",
        ", switch:off:Apple SMC power/lid events, exec, hyprctl dispatch dpms on",
        ", switch:off:Apple SMC power/lid events, exec, brightnessctl --device='kbd_backlight' set 100%"
    },
    input = {
        kb_options = "altwin:swap_alt_win",
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            clickfinger_behavior = true,
        }
    },
    gesture = {
        "3, horizontal, workspace",
        "3, up, fullscreen",
        "3, down, togglefloating",
        "4, horizontal, workspace"
    }
})
