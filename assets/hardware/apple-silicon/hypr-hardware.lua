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
