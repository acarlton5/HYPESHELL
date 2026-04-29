import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root
    property var map: ({})
    property bool darkMode: Config.runtime.appearance.theme === "dark"
    property var activeColors: ({})

    function getActiveColors(themeId, mode) {
        const info = map[themeId]
        if (!info || info.type !== "unified") return null
        
        // This is a placeholder for actual JSON parsing if needed in-memory
        // In practice, switchTheme.sh handles the file-level update, 
        // but this allows for UI-level previews.
        return null 
    }

    onDarkModeChanged: {
        Ipc.applyThemeMode(darkMode ? "dark" : "light")
    }

    function notifyMissingVariant(theme, variant) {
        Quickshell.execDetached(["notify-send", "Hype Shell", `Theme '${theme}' does not have a ${variant} variant.`, "--urgency=normal", "--expire-time=5000"]);
    }

    Timer {
        interval: 5000
        repeat: true 
        running: true 
        onTriggered: loadThemes.running = true
    }

    Process {
        id: loadThemes

        command: [
            "bash", "-c",
            "ls -1 " + Directories.shellConfig + "/colorschemes/*.json 2>/dev/null; " +
            "find " + Directories.shellConfig + "/themes -maxdepth 2 -name 'qml-settings.json' -exec bash -c 'echo \"{}\"; grep -q \"colorsLight\" \"{}\" && echo \"true\" || echo \"false\"' \\; 2>/dev/null"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const map = {};
                const lines = text.split("\n").map((t) => t.trim()).filter((t) => t.length > 0);
                for (let i = 0; i < lines.length; i++) {
                    const t = lines[i];
                    if (t.endsWith(".json") && t.includes("/colorschemes/")) {
                        const name = t.split("/").pop().replace(/\.json$/, "");
                        const parts = name.split("-");
                        const variant = parts.pop();
                        const base = parts.join("-");
                        if (!map[base]) map[base] = { id: base, type: "legacy" };
                        map[base][variant] = name;
                    } else if (t.endsWith("qml-settings.json")) {
                        const hasLight = lines[++i] === "true";
                        const pathParts = t.split("/");
                        const themeName = pathParts[pathParts.length - 2];
                        if (!map[themeName]) {
                            map[themeName] = { 
                                id: themeName, 
                                type: "unified",
                                path: t.substring(0, t.lastIndexOf("/")),
                                supportsLightDark: hasLight,
                                dark: themeName,
                                light: hasLight ? themeName : null
                            };
                        }
                    }
                }
                root.map = map;
            }
        }
    }

}
