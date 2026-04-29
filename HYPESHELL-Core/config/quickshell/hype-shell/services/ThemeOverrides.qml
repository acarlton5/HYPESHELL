pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.functions

Singleton {
    id: root

    property var overrides: ({})
    property string themeName: WallpaperSlideshow.hypeThemeName
    readonly property var appearanceKeyMap: ({
        m3background: "background",
        m3error: "error",
        m3errorContainer: "error_container",
        m3inverseOnSurface: "inverse_on_surface",
        m3inversePrimary: "inverse_primary",
        m3inverseSurface: "inverse_surface",
        m3onBackground: "on_background",
        m3onError: "on_error",
        m3onErrorContainer: "on_error_container",
        m3onPrimary: "on_primary",
        m3onPrimaryContainer: "on_primary_container",
        m3onSecondary: "on_secondary",
        m3onSecondaryContainer: "on_secondary_container",
        m3onSurface: "on_surface",
        m3onSurfaceVariant: "on_surface_variant",
        m3onTertiary: "on_tertiary",
        m3onTertiaryContainer: "on_tertiary_container",
        m3outline: "outline",
        m3outlineVariant: "outline_variant",
        m3primary: "primary",
        m3primaryContainer: "primary_container",
        m3scrim: "scrim",
        m3secondary: "secondary",
        m3secondaryContainer: "secondary_container",
        m3shadow: "shadow",
        m3sourceColor: "source_color",
        m3surface: "surface",
        m3surfaceBright: "surface_bright",
        m3surfaceContainer: "surface_container",
        m3surfaceContainerHigh: "surface_container_high",
        m3surfaceContainerHighest: "surface_container_highest",
        m3surfaceContainerLow: "surface_container_low",
        m3surfaceContainerLowest: "surface_container_lowest",
        m3surfaceDim: "surface_dim",
        m3surfaceTint: "surface_tint",
        m3surfaceVariant: "surface_variant",
        m3tertiary: "tertiary",
        m3tertiaryContainer: "tertiary_container"
    })
    
    onThemeNameChanged: refreshOverrides()
    Component.onCompleted: refreshOverrides()

    function refreshOverrides() {
        if (!themeName) {
            overrides = {}
            return
        }
        
        const path = Directories.home + "/.config/hype/themes/" + themeName + "/theme.json"
        loadJsonProc.command = ["cat", FileUtils.trimFileProtocol(path)]
        loadJsonProc.running = true
    }

    Process {
        id: loadJsonProc
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    root.overrides = data
                    console.log("Theme overrides loaded for:", root.themeName)
                    applyConfigOverrides(data.configOverrides || {})
                    applyAppearanceOverrides(data.appearanceOverrides || {})
                } catch (e) {
                    root.overrides = {}
                }
            }
        }
        
        onExited: (exitCode) => {
            if (exitCode !== 0) root.overrides = {}
        }
    }

    function applyConfigOverrides(cfg) {
        for (let key in cfg) {
            setRuntimeValue(key, cfg[key])
        }
    }

    function setRuntimeValue(nestedKey, value) {
        const keys = String(nestedKey || "").split(".").filter((part) => part.length > 0)
        if (keys.length === 0 || !Config.runtime)
            return

        let obj = Config.runtime
        for (let i = 0; i < keys.length - 1; i++) {
            const key = keys[i]
            if (obj[key] === undefined || obj[key] === null)
                obj[key] = {}
            obj = obj[key]
        }

        obj[keys[keys.length - 1]] = value
    }

    function normalizeAppearanceKey(key) {
        const raw = String(key || "")
        if (root.appearanceKeyMap[raw])
            return root.appearanceKeyMap[raw]

        if (raw.indexOf("m3") === 0) {
            const withoutPrefix = raw.slice(2)
            return withoutPrefix.replace(/[A-Z]/g, (match, index) => {
                return (index === 0 ? "" : "_") + match.toLowerCase()
            })
        }

        return raw
    }

    function applyAppearanceOverrides(colors) {
        if (!MaterialColors || !MaterialColors.colors)
            return

        for (let key in colors) {
            const targetKey = normalizeAppearanceKey(key)
            if (MaterialColors.colors[targetKey] !== undefined)
                MaterialColors.colors[targetKey] = colors[key]
        }
    }

    function get(key, defaultValue) {
        if (!overrides || !overrides.configOverrides) return defaultValue
        return overrides.configOverrides[key] !== undefined ? overrides.configOverrides[key] : defaultValue
    }
}
