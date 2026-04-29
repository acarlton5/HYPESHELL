pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property var wallpapers: []
    property bool scanning: false
    property string hypeThemeName: ""
    property string themeWallpaperFolder: resolveThemeWallpaperFolder(hypeThemeName)
    property int intervalSeconds: Config.initialized
        ? Math.max(1, Number(Config.runtime.appearance.background.slideshow.intervalSeconds
            || (Config.runtime.appearance.background.slideshow.interval * 60)
            || 300))
        : 300
    property bool enabled: Config.initialized ? Config.runtime.appearance.background.slideshow.enabled : false
    property bool includeSubfolders: Config.initialized ? Config.runtime.appearance.background.slideshow.includeSubfolders : true
    property bool initializedOnce: false
    property bool hydratingFromConfig: true

    signal wallpaperChanged(string path)

    function bootstrap() {
        if (!Config.initialized)
            return

        root.hydratingFromConfig = false
        root.initializedOnce = true
        root.refreshThemeName()

        if (root.enabled && root.hasThemeFolder() && root.wallpapers.length === 0)
            root.scanFolder()
    }

    function resolveThemeWallpaperFolder(themeName) {
        const name = String(themeName || "").trim()
        if (name.length === 0)
            return ""

        const folder = Quickshell.env("HOME") + "/.config/hype/themes/" + name + "/wallpapers"
        if (folder.indexOf("/.config/hype/themes/") < 0)
            return ""
        return folder
    }

    function setTheme(themeName) {
        const nextTheme = String(themeName || "").trim()
        if (nextTheme.length === 0)
            return

        const changed = nextTheme !== root.hypeThemeName
        root.hypeThemeName = nextTheme

        if (!changed && hasThemeFolder())
            scanFolder()
    }

    function refreshThemeName() {
        if (!readHypeThemeProc.running)
            readHypeThemeProc.running = true
    }

    function hasThemeFolder() {
        return String(themeWallpaperFolder || "").trim().length > 0
    }

    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\"'\"'") + "'"
    }

    function buildFindCommand() {
        const folder = String(themeWallpaperFolder || "").trim()
        if (folder.length === 0)
            return ["bash", "-lc", "exit 0"]

        const maxDepth = root.includeSubfolders ? "" : "-maxdepth 1 "
        const qFolder = shellQuote(folder)
        const cmd = "[ -d " + qFolder + " ] || exit 0; " +
            "find " + qFolder + " " + maxDepth +
            "-type f \\( " +
            "-iname '*.jpg' -o " +
            "-iname '*.jpeg' -o " +
            "-iname '*.png' -o " +
            "-iname '*.webp' -o " +
            "-iname '*.bmp' -o " +
            "-iname '*.svg' " +
            "\\)"
        return ["bash", "-lc", cmd]
    }

    function parseWallpaperLines(data) {
        const lines = data.trim().split("\n").filter(line => line.length > 0)
        const unique = []
        const seen = {}

        for (const line of lines) {
            if (seen[line])
                continue
            seen[line] = true
            unique.push(line)
        }

        return unique
    }

    function buildPickCurrentThemeCommand() {
        const maxDepth = root.includeSubfolders ? "" : "-maxdepth 1 "
        const cmd =
            "theme=$(sed -n 's/^hypeTheme=\"\\([^\"]*\\)\"$/\\1/p' \"$HOME/.config/hype/hype.conf\" | head -n1); " +
            "[ -n \"$theme\" ] || exit 0; " +
            "folder=\"$HOME/.config/hype/themes/$theme/wallpapers\"; " +
            "[ -d \"$folder\" ] || exit 0; " +
            "find \"$folder\" " + maxDepth + "-type f \\( " +
            "-iname '*.jpg' -o " +
            "-iname '*.jpeg' -o " +
            "-iname '*.png' -o " +
            "-iname '*.webp' -o " +
            "-iname '*.bmp' -o " +
            "-iname '*.svg' " +
            "\\) | shuf -n1"
        return ["bash", "-lc", cmd]
    }

    function nextWallpaper() {
        if (pickCurrentThemeProcess.running)
            return

        pickCurrentThemeProcess.running = true
    }

    function scanFolder() {
        if (!hasThemeFolder()) {
            wallpapers = []
            return
        }
        wallpapers = []
        scanning = true
        scanProcess.running = true
    }

    Timer {
        id: slideshowTimer
        interval: Math.max(1, root.intervalSeconds) * 1000
        repeat: true
        running: root.enabled && root.initializedOnce
        onTriggered: root.nextWallpaper()
    }

    Process {
        id: readHypeThemeProc
        command: [
            "bash",
            "-lc",
            "sed -n 's/^hypeTheme=\"\\([^\"]*\\)\"$/\\1/p' \"$HOME/.config/hype/hype.conf\" | head -n1"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const nextTheme = String(text || "").trim()
                if (nextTheme.length > 0 && nextTheme !== root.hypeThemeName)
                    root.hypeThemeName = nextTheme
            }
        }
    }

    Process {
        id: scanProcess
        command: root.buildFindCommand()

        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = root.parseWallpaperLines(text || "")
            }
        }

        onExited: (exitCode) => {
            root.scanning = false
            if (exitCode !== 0) {
                console.warn("WallpaperSlideshow: Failed to scan theme folder")
                root.wallpapers = []
            }
        }
    }

    onThemeWallpaperFolderChanged: {
        if (root.hydratingFromConfig)
            return
        if (!hasThemeFolder()) {
            root.wallpapers = []
            return
        }
        root.wallpapers = []
        scanning = true
        folderChangeScanProcess.running = true
    }

    Process {
        id: folderChangeScanProcess
        command: root.buildFindCommand()

        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = root.parseWallpaperLines(text || "")
            }
        }

        onExited: (exitCode) => {
            root.scanning = false
            if (exitCode !== 0) {
                console.warn("WallpaperSlideshow: Failed to scan theme folder")
                root.wallpapers = []
            }
        }
    }

    Process {
        id: pickCurrentThemeProcess
        command: root.buildPickCurrentThemeCommand()

        stdout: StdioCollector {
            onStreamFinished: {
                const picked = String(text || "").trim()
                if (picked.length === 0)
                    return

                const selectedPath = "file://" + encodeURI(picked)
                Config.updateKey("appearance.background.path", selectedPath)
                wallpaperChanged(selectedPath)

                if (Config.runtime.appearance.colors.autogenerated) {
                    Quickshell.execDetached([
                        "hype", "ipc", "call", "global", "regenColors"
                    ])
                }
            }
        }
    }

    onIncludeSubfoldersChanged: {
        if (hasThemeFolder())
            scanFolder()
    }

    onEnabledChanged: {
        if (enabled && wallpapers.length === 0 && hasThemeFolder())
            scanFolder()
    }

    Timer {
        id: themeWatchTimer
        interval: 1500
        repeat: true
        running: root.initializedOnce
        onTriggered: root.refreshThemeName()
    }

    Connections {
        target: Config
        function onInitializedChanged() {
            root.bootstrap()
        }
    }

    Component.onCompleted: root.bootstrap()
}
