import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
pragma Singleton

Singleton {
    id: root

    signal colorGenerationStarted()
    signal colorGenerationCompleted(var colors)
    signal colorGenerationFailed(string error)

    property var lastGeneratedColors: ({})

    function generateThemeFromWallpaper(wallpaperPath, mode = "dark") {
        if (!wallpaperPath || wallpaperPath.length === 0) {
            colorGenerationFailed("No wallpaper path provided")
            return
        }

        colorGenerationStarted()

        const method = Config.runtime.appearance?.wallbash?.method ?? "auto"
        const pathToUse = wallpaperPath.startsWith("file://")
            ? wallpaperPath.substring(7)
            : wallpaperPath

        if (method === "pywal" || method === "auto") {
            generateWithPywal(pathToUse, mode)
        } else {
            generateWithNative(pathToUse, mode)
        }
    }

    function generateWithPywal(wallpaperPath, mode) {
        extractProcess.wallpaperPath = wallpaperPath
        extractProcess.method = "pywal"
        extractProcess.themeMode = mode
        extractProcess.command = ["bash", "-c", `wal -i "${wallpaperPath}" -q && cat ~/.config/wal/colorscheme.json`]
        extractProcess.running = true
    }

    function generateWithNative(wallpaperPath, mode) {
        extractProcess.wallpaperPath = wallpaperPath
        extractProcess.method = "native"
        extractProcess.themeMode = mode
        extractProcess.command = ["bash", Directories.scriptsPath + "/interface/wallbash-native.sh", wallpaperPath]
        extractProcess.running = true
    }

    Process {
        id: extractProcess

        property string wallpaperPath
        property string method: "auto"
        property string themeMode: "dark"

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const output = text.trim()
                    if (method === "pywal") {
                        const jsonStart = output.lastIndexOf("{")
                        const jsonStr = output.substring(jsonStart)
                        const parsed = JSON.parse(jsonStr)

                        if (parsed.colors && Array.isArray(parsed.colors)) {
                            const generatedColors = generatePaletteFromPywal(parsed.colors, themeMode)
                            root.lastGeneratedColors = generatedColors
                            root.colorGenerationCompleted(generatedColors)
                        } else {
                            root.colorGenerationFailed("Invalid pywal output format")
                        }
                    } else {
                        const generatedColors = JSON.parse(output)
                        root.lastGeneratedColors = generatedColors
                        root.colorGenerationCompleted(generatedColors)
                    }
                } catch (e) {
                    root.colorGenerationFailed(`Color extraction failed: ${e}`)
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.error("Wallbash error:", text)
                    if (!extractProcess.running) {
                        root.colorGenerationFailed(`Process error: ${text}`)
                    }
                }
            }
        }
    }

    function generatePaletteFromPywal(colors, mode) {
        if (!Array.isArray(colors) || colors.length < 8) {
            return defaultPalette(mode)
        }

        const palette = {
            colorsDark: {
                surface: colors[0],
                surfaceOverlay: colors[0] + "99",
                surfaceOverlaySoft: colors[0] + "cc",
                primary: colors[4],
                text: colors[7],
                mutedText: colors[8] || colors[7],
                accent: colors[5],
                accentSecondary: colors[4],
                error: colors[1]
            },
            colorsLight: {
                surface: colors[7],
                surfaceOverlay: colors[7] + "99",
                surfaceOverlaySoft: colors[7] + "cc",
                primary: adjustBrightness(colors[4], 30),
                text: colors[0],
                mutedText: colors[2],
                accent: adjustBrightness(colors[5], 20),
                accentSecondary: adjustBrightness(colors[4], 30),
                error: adjustBrightness(colors[1], 30)
            }
        }

        return palette
    }

    function adjustBrightness(color, percent) {
        const hex = color.replace("#", "")
        const r = parseInt(hex.substr(0, 2), 16)
        const g = parseInt(hex.substr(2, 2), 16)
        const b = parseInt(hex.substr(4, 2), 16)

        const adjusted = Math.round(Math.min(255, r + (255 - r) * percent / 100))
        const adjG = Math.round(Math.min(255, g + (255 - g) * percent / 100))
        const adjB = Math.round(Math.min(255, b + (255 - b) * percent / 100))

        return "#" + [adjusted, adjG, adjB]
            .map(x => x.toString(16).padStart(2, "0"))
            .join("")
    }

    function defaultPalette(mode) {
        return {
            colorsDark: {
                surface: "#1e1e2e",
                surfaceOverlay: "#1e1e2e99",
                surfaceOverlaySoft: "#1e1e2ecc",
                primary: "#a6e3a1",
                text: "#cdd6f4",
                mutedText: "#6c7086",
                accent: "#f38ba8",
                accentSecondary: "#f2d5cf",
                error: "#f38ba8"
            },
            colorsLight: {
                surface: "#eff1f5",
                surfaceOverlay: "#eff1f599",
                surfaceOverlaySoft: "#eff1f5cc",
                primary: "#40a02b",
                text: "#4c4f69",
                mutedText: "#9ca0b0",
                accent: "#d20f39",
                accentSecondary: "#df8e1d",
                error: "#d20f39"
            }
        }
    }
}
