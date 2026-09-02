hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("$HOME/DevBox/quickshell_menu/toggle.sh"))
hl.bind("switch:on:Apple SMC power/lid events", hl.dsp.exec_cmd("hype ipc call lock lock"), {
    locked = true,
})
hl.bind("switch:off:Apple SMC power/lid events", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "enable" }))
    end, { timeout = 500, type = "oneshot" })
end, { locked = true })
hl.bind("switch:off:Apple SMC power/lid events", hl.dsp.exec_cmd("brightnessctl --device='kbd_backlight' set 100%"), {
    locked = true,
})

hl.config({
    input = {
        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            scroll_factor = 0.5,
        }
    },
    gestures = {
        workspace_swipe = true,
        workspace_swipe_fingers = 3,
        workspace_swipe_distance = 300,
        workspace_swipe_invert = true,
        workspace_swipe_create_new = true,
    }
})
