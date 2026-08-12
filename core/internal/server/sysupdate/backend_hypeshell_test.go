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
		`systemd-run --user --collect --on-active=2s /usr/bin/systemctl --user restart hype.service`,
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
func TestShortPluginRevision(t *testing.T) {
	tests := []struct {
		revision string
		fallback string
		want     string
	}{
		{revision: "264a77a1234567890", fallback: "missing", want: "264a77a12345"},
		{revision: "264a77a", fallback: "missing", want: "264a77a"},
		{revision: "", fallback: "missing", want: "missing"},
	}

	for _, test := range tests {
		if got := shortPluginRevision(test.revision, test.fallback); got != test.want {
			t.Fatalf("shortPluginRevision(%q, %q) = %q, want %q", test.revision, test.fallback, got, test.want)
		}
	}
}
