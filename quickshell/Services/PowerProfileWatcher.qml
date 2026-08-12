pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property string backendName: ""
    property int currentProfile: PowerProfile.Balanced
    property int previousProfile: -1

    readonly property bool hasPerformanceProfile: available && PowerProfiles.hasPerformanceProfile
    readonly property int degradationReason: available ? PowerProfiles.degradationReason : PerformanceDegradationReason.None
    readonly property var profiles: [PowerProfile.PowerSaver, PowerProfile.Balanced].concat(hasPerformanceProfile ? [PowerProfile.Performance] : [])
    // Compatibility name for HypeBar components from older installed builds.
    readonly property var currentProfiles: profiles

    signal profileChanged(int profile)

    function refreshAvailability() {
        backendProbe.running = true;
    }

    function setProfile(profile) {
        if (!available)
            return false;
        PowerProfiles.profile = profile;
        return true;
    }

    function stepProfile(direction) {
        if (!available)
            return false;
        const index = profiles.findIndex(candidate => candidate === currentProfile);
        const nextIndex = index + direction;
        if (index < 0 || nextIndex < 0 || nextIndex >= profiles.length)
            return false;
        return setProfile(profiles[nextIndex]);
    }

    Process {
        id: backendProbe
        command: ["sh", "-c", "busctl --system status org.freedesktop.UPower.PowerProfiles >/dev/null 2>&1"]
        running: false
        onExited: exitCode => {
            root.available = exitCode === 0;
            if (!root.available) {
                root.backendName = "";
                return;
            }
            backendNameProbe.running = true;
            root.currentProfile = PowerProfiles.profile;
            if (root.previousProfile === -1)
                root.previousProfile = root.currentProfile;
        }
    }

    Process {
        id: backendNameProbe
        command: ["sh", "-c", "if pgrep -x tuned-ppd >/dev/null 2>&1; then echo tuned-ppd; else echo power-profiles-daemon; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.backendName = text.trim()
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: root.refreshAvailability()
    }

    Connections {
        target: PowerProfiles

        function onProfileChanged() {
            if (!root.available)
                return;
            root.previousProfile = root.currentProfile;
            root.currentProfile = PowerProfiles.profile;
            if (root.previousProfile !== -1 && root.previousProfile !== root.currentProfile)
                root.profileChanged(root.currentProfile);
        }
    }

    Component.onCompleted: refreshAvailability()
}
