package sysupdate

import (
	"os/exec"
	"strings"
	"testing"
)

func TestHypeShellSelfUpdateScriptHardwareProfile(t *testing.T) {
	script := hypeShellSelfUpdateScript("1001", "testuser", "/home/testuser", "/run/user/1001", "unix:path=/run/user/1001/bus")
	for _, expected := range []string{
		`hardware_profile="apple-silicon"`,
		`assets/hardware/apple-silicon/hypr-hardware.lua`,
		`require("hype.hardware")`,
		`install -o "$update_user" -g "$user_group" -m 644 /dev/null "$user_hardware_file"`,
		`plugin_root="$update_home/.config/HypeShell/plugins"`,
		`runuser -u "$update_user" -- env HOME="$update_home"`,
		`/usr/local/bin/hype plugins update "$plugin_id"`,
		`Warning: could not update plugin $plugin_id`,
	} {
		if !strings.Contains(script, expected) {
			t.Fatalf("self-update script missing %q", expected)
		}
	}

	cmd := exec.Command("bash", "-n")
	cmd.Stdin = strings.NewReader(script)
	if output, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("self-update script has invalid shell syntax: %v\n%s", err, output)
	}
}
