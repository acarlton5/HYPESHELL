import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.modules.functions
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    title: "Sound"
    description: "Volume and audio devices"
    readonly property var sinkNode: Volume.defaultSink
    readonly property var sourceNode: Volume.defaultSource
    readonly property real sinkVol: Volume.nodeVolume(sinkNode)
    readonly property bool sinkMuted: Volume.isMuted(sinkNode)
    readonly property real sourceVol: Volume.nodeVolume(sourceNode)
    readonly property bool sourceMuted: Volume.isMuted(sourceNode)

    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(20)

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(16)

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: Metrics.radius("large")
                    color: Appearance.m3colors.m3primaryContainer

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "volume_up"
                        color: Appearance.m3colors.m3onPrimaryContainer
                        iconSize: Metrics.iconSize(24)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Output"
                        font.pixelSize: Metrics.fontSize(16)
                        font.family: Metrics.fontFamily("Outfit Medium")
                        color: Appearance.m3colors.m3onSurface
                    }

                    StyledText {
                        text: sinkNode?.description ?? "No output device"
                        font.pixelSize: Metrics.fontSize(13)
                        color: Appearance.m3colors.m3onSurfaceVariant
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.m3colors.m3outlineVariant
                opacity: 0.4
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(12)

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Volume"
                        font.pixelSize: Metrics.fontSize(14)
                        font.family: Metrics.fontFamily("Outfit Medium")
                        color: Appearance.m3colors.m3onSurface
                    }

                    Item { Layout.fillWidth: true }

                    StyledText {
                        animate: false
                        text: Math.round(sinkVol * 100) + "%"
                        font.pixelSize: Metrics.fontSize(14)
                        font.family: Metrics.fontFamily("Outfit SemiBold")
                        color: Appearance.m3colors.m3primary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(16)

                    MaterialSymbol {
                        icon: sinkMuted ? "volume_off"
                              : sinkVol < 0.33 ? "volume_mute"
                              : sinkVol < 0.66 ? "volume_down"
                              : "volume_up"
                        color: Appearance.m3colors.m3onSurfaceVariant
                        iconSize: Metrics.iconSize(24)
                    }

                    StyledSlider {
                        id: outputVolumeSlider
                        Layout.fillWidth: true
                        value: sinkVol * 100
                        enabled: !!sinkNode?.audio
                        onValueChanged: {
                            if (sinkNode?.audio)
                                Volume.setVolume(value / 100)
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(8)

                StyledText {
                    text: "Device"
                    font.pixelSize: Metrics.fontSize(14)
                    font.family: Metrics.fontFamily("Outfit Medium")
                    color: Appearance.m3colors.m3onSurface
                }

                StyledDropDown {
                    Layout.fillWidth: true
                    label: "Output device"
                    model: Volume.sinks.map(d => d.description || d.name || "Unknown output")
                    currentIndex: {
                        for (let i = 0; i < Volume.sinks.length; i++)
                            if (Volume.sinks[i].name === sinkNode?.name) return i
                        return -1
                    }
                    onSelectedIndexChanged: index => {
                        if (index >= 0 && index < Volume.sinks.length)
                            Volume.setDefaultSink(Volume.sinks[index])
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: Metrics.radius("small")
                color: Appearance.m3colors.m3surfaceContainerHigh

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Metrics.margin(16)
                    anchors.rightMargin: Metrics.margin(16)
                    spacing: Metrics.spacing(12)

                    MaterialSymbol {
                        icon: sinkMuted ? "volume_off" : "volume_up"
                        color: sinkMuted ? Appearance.m3colors.m3error : Appearance.m3colors.m3onSurfaceVariant
                        iconSize: Metrics.iconSize(24)
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Mute output"
                        font.pixelSize: Metrics.fontSize(14)
                        color: Appearance.m3colors.m3onSurface
                    }

                    StyledSwitch {
                        checked: sinkMuted
                        enabled: !!sinkNode?.audio
                        onToggled: {
                            if (sinkNode?.audio)
                                Volume.toggleMuted(sinkNode)
                        }
                    }
                }
            }
        }
    }

    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(20)

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(16)

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: Metrics.radius("large")
                    color: Appearance.m3colors.m3secondaryContainer

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "mic"
                        color: Appearance.m3colors.m3onSecondaryContainer
                        iconSize: Metrics.iconSize(24)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(2)

                    StyledText {
                        text: "Input"
                        font.pixelSize: Metrics.fontSize(16)
                        font.family: Metrics.fontFamily("Outfit Medium")
                        color: Appearance.m3colors.m3onSurface
                    }

                    StyledText {
                        visible: Volume.sources.length > 0
                        text: sourceNode?.description ?? "No input device"
                        font.pixelSize: Metrics.fontSize(13)
                        color: Appearance.m3colors.m3onSurfaceVariant
                    }
                }
            }

            Rectangle {
                visible: Volume.sources.length === 0
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: Metrics.radius("small")
                color: Appearance.m3colors.m3surfaceContainerHigh

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Metrics.spacing(8)

                    MaterialSymbol {
                        icon: "mic_off"
                        iconSize: Metrics.iconSize(48)
                        color: ColorUtils.transparentize(Appearance.m3colors.m3onSurface, 0.3)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledText {
                        text: "No input devices"
                        font.pixelSize: Metrics.fontSize(14)
                        font.family: Metrics.fontFamily("Outfit Medium")
                        color: Appearance.m3colors.m3onSurfaceVariant
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                visible: Volume.sources.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.m3colors.m3outlineVariant
                opacity: 0.4
            }

            ColumnLayout {
                visible: Volume.sources.length > 0
                Layout.fillWidth: true
                spacing: Metrics.spacing(12)

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Volume"
                        font.pixelSize: Metrics.fontSize(14)
                        font.family: Metrics.fontFamily("Outfit Medium")
                        color: Appearance.m3colors.m3onSurface
                    }

                    Item { Layout.fillWidth: true }

                    StyledText {
                        animate: false
                        text: Math.round(sourceVol * 100) + "%"
                        font.pixelSize: Metrics.fontSize(14)
                        font.family: Metrics.fontFamily("Outfit SemiBold")
                        color: Appearance.m3colors.m3primary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(16)

                    MaterialSymbol {
                        icon: sourceMuted ? "mic_off" : "mic"
                        color: Appearance.m3colors.m3onSurfaceVariant
                        iconSize: Metrics.iconSize(24)
                    }

                    StyledSlider {
                        id: inputVolumeSlider
                        Layout.fillWidth: true
                        value: sourceVol * 100
                        enabled: !!sourceNode?.audio
                        onValueChanged: {
                            if (sourceNode?.audio)
                                Volume.setSourceVolume(value / 100)
                        }
                    }
                }
            }

            ColumnLayout {
                visible: Volume.sources.length > 0
                Layout.fillWidth: true
                spacing: Metrics.spacing(8)

                StyledText {
                    text: "Device"
                    font.pixelSize: Metrics.fontSize(14)
                    font.family: Metrics.fontFamily("Outfit Medium")
                    color: Appearance.m3colors.m3onSurface
                }

                StyledDropDown {
                    Layout.fillWidth: true
                    label: "Input device"
                    model: Volume.sources.map(d => d.description || d.name || "Unknown input")
                    currentIndex: {
                        for (let i = 0; i < Volume.sources.length; i++)
                            if (Volume.sources[i].name === sourceNode?.name) return i
                        return -1
                    }
                    onSelectedIndexChanged: index => {
                        if (index >= 0 && index < Volume.sources.length)
                            Volume.setDefaultSource(Volume.sources[index])
                    }
                }
            }

            Rectangle {
                visible: Volume.sources.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: Metrics.radius("small")
                color: Appearance.m3colors.m3surfaceContainerHigh

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Metrics.margin(16)
                    anchors.rightMargin: Metrics.margin(16)
                    spacing: Metrics.spacing(12)

                    MaterialSymbol {
                        icon: sourceMuted ? "mic_off" : "mic"
                        color: sourceMuted ? Appearance.m3colors.m3error : Appearance.m3colors.m3onSurfaceVariant
                        iconSize: Metrics.iconSize(24)
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Mute input"
                        font.pixelSize: Metrics.fontSize(14)
                        color: Appearance.m3colors.m3onSurface
                    }

                    StyledSwitch {
                        checked: sourceMuted
                        enabled: !!sourceNode?.audio
                        onToggled: {
                            if (sourceNode?.audio)
                                Volume.toggleMuted(sourceNode)
                        }
                    }
                }
            }
        }
    }
}
