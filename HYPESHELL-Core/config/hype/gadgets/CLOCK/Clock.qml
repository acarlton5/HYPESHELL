import "../../components/morphedPolygons/geometry/offset.js" as Offset
import "../../components/morphedPolygons/material-shapes.js" as MaterialShapes // For polygons
import "../../components/morphedPolygons/shapes/corner-rounding.js" as CornerRounding
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.modules.components
import qs.modules.components.morphedPolygons
import qs.services

Scope {
    id: root

    property bool imageFailed: false
    property var screenRef: null

    Variants {
        model: root.screenRef ? [root.screenRef] : Quickshell.screens

        PanelWindow {
            id: clock

            required property var modelData
            property int placementMargin: 50
            property int clockHeight: 250
            property int clockWidth: 250
            property int visualPadding: 0

            function setRandomPosition() {
                const margin = clockDrag.edgeMargin;
                const minX = Math.max(0, margin);
                const minY = Math.max(0, margin);
                const maxX = Math.max(minX, width - rootContentContainer.width - margin);
                const maxY = Math.max(minY, height - rootContentContainer.height - margin);
                const x = minX + Math.floor(Math.random() * (maxX - minX + 1));
                const y = minY + Math.floor(Math.random() * (maxY - minY + 1));
                animX.to = x;
                animY.to = y;
                moveAnim.start();
                Config.updateKey("appearance.background.clock.xPos", x);
                Config.updateKey("appearance.background.clock.yPos", y);
            }

            color: "transparent"
            visible: (Config.runtime.appearance.background.clock.enabled && Config.initialized && !imageFailed)
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom
            screen: modelData

            ParallelAnimation {
                id: moveAnim

                NumberAnimation {
                    id: animX

                    target: rootContentContainer
                    property: "x"
                    duration: Metrics.chronoDuration(400)
                    easing.type: Easing.InOutCubic
                }

                NumberAnimation {
                    id: animY

                    target: rootContentContainer
                    property: "y"
                    duration: Metrics.chronoDuration(400)
                    easing.type: Easing.InOutCubic
                }

            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Item {
                id: rootContentContainer

                property real releasedX: 0
                property real releasedY: 0
                function clampToVisible() {
                    const margin = clockDrag.edgeMargin;
                    const minX = Math.max(0, margin);
                    const minY = Math.max(0, margin);
                    const maxX = Math.max(minX, clock.width - width - margin);
                    const maxY = Math.max(minY, clock.height - height - margin);
                    x = Math.max(minX, Math.min(maxX, x));
                    y = Math.max(minY, Math.min(maxY, y));
                }
                function savePosition() {
                    clampToVisible();
                    Config.updateKey("appearance.background.clock.xPos", x);
                    Config.updateKey("appearance.background.clock.yPos", y);
                }

                height: clockHeight + clock.visualPadding * 2
                width: clockWidth + clock.visualPadding * 2
                Component.onCompleted: {
                    Qt.callLater(() => {
                        x = Config.runtime.appearance.background.clock.xPos;
                        y = Config.runtime.appearance.background.clock.yPos;
                        clampToVisible();
                        Config.updateKey("appearance.background.clock.xPos", x);
                        Config.updateKey("appearance.background.clock.yPos", y);
                    });
                }
                onWidthChanged: clampToVisible()
                onHeightChanged: clampToVisible()

                Item {
                    id: digitalClockContainer

                    visible: !Config.runtime.appearance.background.clock.isAnalog
                    anchors.fill: parent

                    StyledRect {
                        anchors.fill: parent
                        radius: Metrics.radius("large")
                        color: Appearance.m3colors.m3secondaryContainer
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: Metrics.spacing(-28)

                        StyledText {
                            animate: false
                            text: Time.format("hh:mm")
                            font.pixelSize: Metrics.fontSize(Appearance.font.size.wildass * 3)
                            font.family: Metrics.fontFamily("main")
                            font.bold: true
                            color: Appearance.colors.colOnSecondaryContainer
                            horizontalAlignment: Text.AlignHCenter
                            width: digitalClockContainer.width
                        }

                        StyledText {
                            animate: false
                            text: Time.format("dddd, dd/MM")
                            font.pixelSize: Metrics.fontSize(30)
                            font.family: Metrics.fontFamily("main")
                            font.bold: true
                            color: Appearance.colors.colOnSecondaryContainer
                            horizontalAlignment: Text.AlignHCenter
                            width: digitalClockContainer.width
                        }

                    }

                }

                Item {
                    id: analogClockContainer

                    property int hours: parseInt(Time.format("hh"))
                    property int minutes: parseInt(Time.format("mm"))
                    property int seconds: parseInt(Time.format("ss"))
                    readonly property real cx: width / 2
                    readonly property real cy: height / 2
                    property var shapes: [MaterialShapes.getCookie7Sided, MaterialShapes.getCookie9Sided, MaterialShapes.getCookie12Sided, MaterialShapes.getPixelCircle, MaterialShapes.getCircle, MaterialShapes.getGhostish]

                    anchors.fill: parent
                    visible: Config.runtime.appearance.background.clock.isAnalog

                    // Polygon
                    MorphedPolygon {
                        id: shapeCanvas

                        anchors.fill: parent
                        color: Appearance.m3colors.m3secondaryContainer
                        roundedPolygon: analogClockContainer.shapes[Config.runtime.appearance.background.clock.shape]()

                        transform: Rotation {
                            origin.x: shapeCanvas.width / 2
                            origin.y: shapeCanvas.height / 2
                            angle: shapeCanvas.rotation
                        }

                        NumberAnimation on rotation {
                            from: 0
                            to: 360
                            running: Config.runtime.appearance.animations.enabled && Config.runtime.appearance.background.clock.rotatePolygonBg
                            duration: Config.runtime.appearance.background.clock.rotationDuration * 1000
                            loops: Animation.Infinite
                        }
                    }

                    ClockDial {
                        id: dial
                        anchors.fill: parent
                        anchors.margins: parent.width * 0.12
                        color: Appearance.colors.colOnSecondaryContainer
                        z: 0
                    }

                    // Hour hand
                    StyledRect {
                        z: 2
                        width: 10
                        height: parent.height * 0.3
                        radius: Metrics.radius("full")
                        color: Qt.darker(Appearance.m3colors.m3secondary, 0.8)
                        x: analogClockContainer.cx - width / 2
                        y: analogClockContainer.cy - height
                        transformOrigin: Item.Bottom
                        rotation: (analogClockContainer.hours % 12 + analogClockContainer.minutes / 60) * 30
                    }

                    StyledRect {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        radius: width / 2
                        color: Appearance.m3colors.m3secondary
                        z: 99 // Ensures its on top of everthing

                        // Inner dot
                        StyledRect {
                            width: parent.width / 2
                            height: parent.height / 2
                            radius: width / 2
                            anchors.centerIn: parent
                            z: 100
                            color: Appearance.m3colors.m3primaryContainer
                        }

                    }

                    // Minute hand
                    StyledRect {
                        width: 18
                        height: parent.height * 0.35
                        radius: Metrics.radius("full")
                        color: Appearance.m3colors.m3secondary
                        x: analogClockContainer.cx - width / 2
                        y: analogClockContainer.cy - height
                        transformOrigin: Item.Bottom
                        rotation: analogClockContainer.minutes * 6
                        z: 10 // On top of all hands
                    }

                    // Second hand
                    StyledRect {
                        visible: true
                        width: 4
                        height: parent.height * 0.28
                        radius: Metrics.radius("full")
                        color: Appearance.m3colors.m3error
                        x: analogClockContainer.cx - width / 2
                        y: analogClockContainer.cy - height
                        transformOrigin: Item.Bottom
                        rotation: analogClockContainer.seconds * 6
                        z: 2
                    }

                    StyledText {
                        text: Time.format("hh")
                        anchors.top: parent.top 
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: Metrics.margin(30)
                        font.pixelSize: Metrics.fontSize(80)
                        font.bold: true
                        opacity: 0.3
                        animate: false
                    }

                    StyledText {
                        text: Time.format("mm")
                        anchors.top: parent.top 
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: Metrics.margin(110)
                        font.pixelSize: Metrics.fontSize(80)
                        font.bold: true
                        opacity: 0.3
                        animate: false
                    }

                    IpcHandler {
                        function changePosition() {
                            clock.setRandomPosition();
                        }

                        target: "clock"
                    }

                }

                DesktopModuleDrag {
                    id: clockDrag
                    anchors.fill: parent
                    target: rootContentContainer
                    bounds: clock
                    edgeMargin: clock.placementMargin
                    onDragFinished: rootContentContainer.savePosition()
                }

            }

            mask: Region {
                x: clockDrag.dragging ? 0 : rootContentContainer.x
                y: clockDrag.dragging ? 0 : rootContentContainer.y
                width: clockDrag.dragging ? clock.width : rootContentContainer.width
                height: clockDrag.dragging ? clock.height : rootContentContainer.height
            }

        }

    }

}
