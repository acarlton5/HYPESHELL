pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property string localFingerprint: "Unknown"
    property string remoteFingerprint: "Unknown"
    property bool updateAvailable: remoteFingerprint !== "Unknown" && localFingerprint !== remoteFingerprint
    property string status: "Idle"
    
    readonly property string remoteUrl: "https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-Installer/install.sh"

    Component.onCompleted: {
        console.log("[UpdateService] Loaded and ready.");
        checkForUpdates();
    }

    function checkForUpdates() {
        console.log("[UpdateService] Checking fingerprints...");
        root.status = "Checking...";
        readLocalProc.running = false;
        readLocalProc.running = true;
        fetchRemoteProc.running = false;
        fetchRemoteProc.running = true;
    }

    function runUpdate() {
        console.log("[UpdateService] Executing one-click installer...");
        root.status = "Installing...";
        Quickshell.execDetached(["notify-send", "Hype Shell", "Update starting...", "--urgency=normal"]);
        
        updateProc.running = false;
        updateProc.command = ["bash", "-c", "curl -fsSL " + remoteUrl + " | bash"];
        updateProc.running = true;
    }

    Process {
        id: updateProc
        onExited: {
            console.log("[UpdateService] Installer finished.");
            root.status = "Idle";
            Quickshell.execDetached(["notify-send", "Hype Shell", "Update process completed.", "--urgency=normal"]);
            checkForUpdates();
        }
    }

    Process {
        id: readLocalProc
        command: ["cat", Directories.home + "/.config/hype/version"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.localFingerprint = (text || "").trim();
                console.log("[UpdateService] Local Fingerprint: " + root.localFingerprint);
                if (root.status === "Checking...") root.status = "Idle";
            }
        }
    }

    Process {
        id: fetchRemoteProc
        command: ["curl", "-fsSL", remoteUrl]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].indexOf("export BUILD_FINGERPRINT=") !== -1) {
                        const parts = lines[i].split('"');
                        if (parts.length >= 2) {
                            root.remoteFingerprint = parts[1];
                            console.log("[UpdateService] Remote Fingerprint: " + root.remoteFingerprint);
                        }
                        break;
                    }
                }
                if (root.status === "Checking...") root.status = "Idle";
            }
        }
    }

    Timer {
        interval: 600000 // 10 minutes
        running: true
        repeat: true
        onTriggered: checkForUpdates()
    }
}
