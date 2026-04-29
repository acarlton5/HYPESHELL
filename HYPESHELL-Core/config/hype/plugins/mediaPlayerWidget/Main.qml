import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.config
import qs.modules.components

Scope {
    id: globalRoot

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: mediaWidgetWindow
            required property var modelData
            property int placementMargin: 50
            property string positionPreset: {
                if (!Config.runtime || !Config.runtime.plugins || !Config.runtime.plugins.mediaPlayerWidget)
                    return "top-center"
                const preset = Config.runtime.plugins.mediaPlayerWidget.positionPreset
                if (preset === undefined || preset === null)
                    return "top-center"
                const text = String(preset).trim()
                return text.length > 0 ? text : "top-center"
            }
            property bool peekActive: false
            property string peekRequest: Config.runtime.plugins.mediaPlayerWidget.peekRequest ?? ""
            property int peekDurationMs: Config.runtime.plugins.mediaPlayerWidget.peekDurationMs ?? 5000
            property string lastPeekRequest: ""

            color: "transparent"
            visible: Config.runtime.plugins.mediaPlayerWidget.enabled && Config.initialized
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "hype:gadget-media"
            WlrLayershell.layer: peekActive ? WlrLayer.Overlay : WlrLayer.Bottom
            screen: modelData
            onWidthChanged: {
                if (rootContentContainer.initialized) {
                    rootContentContainer.placeWidget()
                }
            }
            onHeightChanged: {
                if (rootContentContainer.initialized) {
                    rootContentContainer.placeWidget()
                }
            }
            onPeekRequestChanged: {
                if (peekRequest.length > 0 && peekRequest !== lastPeekRequest) {
                    lastPeekRequest = peekRequest
                    showAboveWindows(peekDurationMs)
                }
            }
            onPositionPresetChanged: {
                if (rootContentContainer.initialized) {
                    rootContentContainer.placeWidget()
                }
            }

            anchors { top: true; bottom: true; left: true; right: true }

            function showAboveWindows(durationMs) {
                peekActive = true
                peekTimer.interval = Math.max(250, durationMs)
                peekTimer.restart()
            }

            Timer {
                id: peekTimer
                interval: 5000
                repeat: false
                onTriggered: mediaWidgetWindow.peekActive = false
            }

            Item {
                id: rootContentContainer
                width: widget.implicitWidth
                height: widget.implicitHeight
                property bool initialized: false

                function rectsIntersect(ax, ay, aw, ah, bx, by, bw, bh) {
                    return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
                }

                function clampToVisible() {
                    const margin = mediaDrag.edgeMargin
                    const minX = Math.max(0, margin)
                    const minY = Math.max(0, margin)
                    const maxX = Math.max(minX, mediaWidgetWindow.width - width - margin)
                    const maxY = Math.max(minY, mediaWidgetWindow.height - height - margin)
                    x = Math.max(minX, Math.min(maxX, x))
                    y = Math.max(minY, Math.min(maxY, y))
                }

                function applyPresetPosition(preset) {
                    const margin = mediaDrag.edgeMargin
                    const minX = Math.max(0, margin)
                    const minY = Math.max(0, margin)
                    const maxX = Math.max(minX, mediaWidgetWindow.width - width - margin)
                    const maxY = Math.max(minY, mediaWidgetWindow.height - height - margin)

                    switch (preset) {
                    case "top-left":
                        x = minX
                        y = minY
                        break
                    case "top-right":
                        x = maxX
                        y = minY
                        break
                    case "center":
                        x = Math.max(minX, Math.floor((minX + maxX) / 2))
                        y = Math.max(minY, Math.floor((minY + maxY) / 2))
                        break
                    case "bottom-left":
                        x = minX
                        y = maxY
                        break
                    case "bottom-center":
                        x = Math.max(minX, Math.floor((minX + maxX) / 2))
                        y = maxY
                        break
                    case "bottom-right":
                        x = maxX
                        y = maxY
                        break
                    case "custom": {
                        const rawX = Number(Config.runtime.plugins.mediaPlayerWidget.xPos)
                        const rawY = Number(Config.runtime.plugins.mediaPlayerWidget.yPos)
                        x = isNaN(rawX) ? Math.max(minX, Math.floor((minX + maxX) / 2)) : rawX
                        y = isNaN(rawY) ? minY : rawY
                        break
                    }
                    case "top-center":
                    default:
                        x = Math.max(minX, Math.floor((minX + maxX) / 2))
                        y = minY
                        break
                    }
                }

                function clockRect() {
                    if (!Config.runtime.appearance.background.clock.enabled) {
                        return null
                    }

                    const clockVisualPadding = 0
                    const clockWidth = 250 + clockVisualPadding * 2
                    const clockHeight = 250 + clockVisualPadding * 2

                    return {
                        x: Config.runtime.appearance.background.clock.xPos,
                        y: Config.runtime.appearance.background.clock.yPos,
                        width: clockWidth,
                        height: clockHeight
                    }
                }

                function avoidClockOverlap() {
                    const c = clockRect()
                    if (c === null) {
                        return
                    }

                    if (!rectsIntersect(x, y, width, height, c.x, c.y, c.width, c.height)) {
                        return
                    }

                    const m = mediaDrag.edgeMargin
                    const minX = Math.max(0, m)
                    const minY = Math.max(0, m)
                    const maxX = Math.max(minX, mediaWidgetWindow.width - width - m)
                    const maxY = Math.max(minY, mediaWidgetWindow.height - height - m)
                    const candidates = [
                        { x: maxX, y: minY }, // top-right
                        { x: maxX, y: maxY }, // bottom-right
                        { x: minX, y: maxY }, // bottom-left
                        { x: minX, y: minY } // top-left
                    ]

                    for (const p of candidates) {
                        if (!rectsIntersect(p.x, p.y, width, height, c.x, c.y, c.width, c.height)) {
                            x = p.x
                            y = p.y
                            return
                        }
                    }

                    // Fallback: clamp only.
                    clampToVisible()
                }

                function placeWidget() {
                    applyPresetPosition(mediaWidgetWindow.positionPreset)
                    clampToVisible()
                    Config.updateKey("plugins.mediaPlayerWidget.xPos", x)
                    Config.updateKey("plugins.mediaPlayerWidget.yPos", y)
                    initialized = true
                }

                Component.onCompleted: {
                    Qt.callLater(() => {
                        placeWidget()
                    })
                }
                onWidthChanged: if (initialized) placeWidget()
                onHeightChanged: if (initialized) placeWidget()

                MediaPlayerWidget {
                    id: widget
                    anchors.fill: parent
                }

                DesktopModuleDrag {
                    id: mediaDrag
                    anchors.fill: parent
                    target: rootContentContainer
                    bounds: mediaWidgetWindow
                    edgeMargin: mediaWidgetWindow.placementMargin
                    onDragFinished: {
                        Config.updateKey("plugins.mediaPlayerWidget.positionPreset", "custom")
                        Config.updateKey("plugins.mediaPlayerWidget.xPos", rootContentContainer.x)
                        Config.updateKey("plugins.mediaPlayerWidget.yPos", rootContentContainer.y)
                    }
                }
            }

            mask: Region {
                x: mediaDrag.dragging ? 0 : rootContentContainer.x
                y: mediaDrag.dragging ? 0 : rootContentContainer.y
                width: mediaDrag.dragging ? mediaWidgetWindow.width : rootContentContainer.width
                height: mediaDrag.dragging ? mediaWidgetWindow.height : rootContentContainer.height
            }
        }
    }
}
