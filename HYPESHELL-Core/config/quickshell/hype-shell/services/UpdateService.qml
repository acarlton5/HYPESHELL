pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property string localFingerprint: "Unknown"
    property string remoteFingerprint: "Unknown"
    property string remoteVersion: ""
    property string remoteUpdatedAt: ""
    property string lastChecked: "Never"
    property string errorText: ""
    property int lastInstallExitCode: 0
    property bool busy: status === "Checking..." || status === "Installing..."
    property bool remoteKnown: remoteFingerprint !== "Unknown"
    property bool localKnown: localFingerprint !== "Unknown"
    property bool versionUpdateAvailable: isRemoteVersionNewer()
    property bool updateAvailable: remoteKnown && (!localKnown || localFingerprint !== remoteFingerprint || versionUpdateAvailable)
    property string status: "Idle"
    
    readonly property string localVersionPath: Directories.shellConfig + "/version"
    readonly property string fingerprintUrl: "https://raw.githubusercontent.com/acarlton5/HypeUpdater/main/fingerprint"
    readonly property string metadataUrl: "https://raw.githubusercontent.com/acarlton5/HypeUpdater/main/latest.json"
    readonly property string installerUrl: "https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-Installer/install.sh"

    Component.onCompleted: {
        console.log("[UpdateService] Loaded and ready.");
        checkForUpdates();
    }

    function checkForUpdates() {
        console.log("[UpdateService] Checking fingerprints...");
        root.status = "Checking...";
        root.errorText = "";
        localVersionFile.reload();
        readLocalFingerprint();
        fetchRemoteProc.running = false;
        fetchRemoteProc.command = ["curl", "-fsSL", root.fingerprintUrl + "?cacheBust=" + Date.now()];
        fetchRemoteProc.running = true;
        fetchMetadataProc.running = false;
        fetchMetadataProc.command = ["curl", "-fsSL", root.metadataUrl + "?cacheBust=" + Date.now()];
        fetchMetadataProc.running = true;
    }

    function readLocalFingerprint() {
        const value = (localVersionFile.text() || "").trim();
        root.localFingerprint = value.length > 0 ? value.split("\n")[0].trim() : "Unknown";
        console.log("[UpdateService] Local fingerprint path: " + root.localVersionPath);
        console.log("[UpdateService] Local Fingerprint: " + root.localFingerprint);
    }

    function normalizeVersion(value) {
        return String(value || "").trim().replace(/^v/i, "").split(".").map(function(part) {
            const parsed = parseInt(part, 10);
            return isNaN(parsed) ? 0 : parsed;
        });
    }

    function compareVersions(left, right) {
        const a = normalizeVersion(left);
        const b = normalizeVersion(right);
        const length = Math.max(a.length, b.length);

        for (let i = 0; i < length; i++) {
            const ai = i < a.length ? a[i] : 0;
            const bi = i < b.length ? b[i] : 0;
            if (ai < bi)
                return -1;
            if (ai > bi)
                return 1;
        }

        return 0;
    }

    function isRemoteVersionNewer() {
        if (!remoteVersion || remoteVersion.length === 0)
            return false;
        return compareVersions(Config.runtime.shell.version, remoteVersion) < 0;
    }

    function runUpdate() {
        console.log("[UpdateService] Executing one-click installer...");
        root.status = "Installing...";
        root.errorText = "";
        Quickshell.execDetached(["notify-send", "Hype Shell", "Update starting...", "--urgency=normal"]);
        
        updateProc.running = false;
        updateProc.command = ["bash", "-lc", "tmp=$(mktemp); curl -fsSL '" + installerUrl + "?cacheBust=" + Date.now() + "' -o \"$tmp\" && HYPESHELL_UPDATE_ONLY=1 bash \"$tmp\"; code=$?; rm -f \"$tmp\"; exit $code"];
        updateProc.running = true;
    }

    Process {
        id: updateProc
        onExited: (exitCode) => {
            root.lastInstallExitCode = exitCode;
            root.status = "Idle";
            console.log("[UpdateService] Installer finished with exit code: " + exitCode);

            if (exitCode === 0) {
                Quickshell.execDetached(["notify-send", "Hype Shell", "Update installed. Reloading HypeShell...", "--urgency=normal"]);
                checkForUpdates();
                Quickshell.execDetached(["bash", "-lc", "nohup bash -lc 'sleep 1; killall qs quickshell 2>/dev/null || true; if command -v qs >/dev/null 2>&1; then exec qs -c hype-shell; else exec quickshell -c hype-shell; fi' >/dev/null 2>&1 &"]);
            } else {
                root.errorText = "Installer failed with exit code " + exitCode + ".";
                Quickshell.execDetached(["notify-send", "Hype Shell", root.errorText, "--urgency=critical"]);
            }
        }
    }

    FileView {
        id: localVersionFile
        path: root.localVersionPath
        watchChanges: true
        onFileChanged: {
            reload();
            root.readLocalFingerprint();
        }
        onLoaded: root.readLocalFingerprint()
        onLoadFailed: {
            root.localFingerprint = "Unknown";
            console.warn("[UpdateService] Could not read local fingerprint: " + root.localVersionPath);
        }
    }

    Process {
        id: fetchRemoteProc
        command: ["curl", "-fsSL", fingerprintUrl]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = (text || "").trim().split("\n")[0].trim();
                root.remoteFingerprint = value.length > 0 ? value : "Unknown";
                root.lastChecked = new Date().toLocaleString();
                console.log("[UpdateService] Remote Fingerprint: " + root.remoteFingerprint);
                if (root.status === "Checking...") root.status = "Idle";
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.remoteFingerprint = "Unknown";
                root.errorText = "Could not reach HypeUpdater.";
                if (root.status === "Checking...") root.status = "Idle";
            }
        }
    }

    Process {
        id: fetchMetadataProc
        command: ["curl", "-fsSL", metadataUrl]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text || "{}");
                    root.remoteVersion = data.version || "";
                    root.remoteUpdatedAt = data.updatedAt || "";
                } catch (e) {
                    root.remoteVersion = "";
                    root.remoteUpdatedAt = "";
                }
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
