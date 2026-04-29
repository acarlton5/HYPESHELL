import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.components
import qs.modules.interface.settings
import qs.services

PanelWindow {
    id: root

    visible: Config.initialized && Globals.visiblility.storeOpen
    focusable: true
    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.35
    }

    StyledRect {
        id: storeSurface

        width: Math.max(360, Math.min(parent.width - Metrics.margin("verylarge"), 1280))
        height: Math.max(460, Math.min(parent.height - Metrics.margin("verylarge"), 760))
        x: Math.max(0, (parent.width - width) / 2)
        y: Math.max(0, (parent.height - height) / 2)
        color: MaterialColors.colors.background
        radius: Appearance.rounding.large

        function clampToScreen() {
            x = Math.max(0, Math.min(x, root.width - width))
            y = Math.max(0, Math.min(y, root.height - height))
        }

        MouseArea {
            z: 10
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            drag.target: storeSurface
            drag.axis: Drag.XAndYAxis
            drag.minimumX: 0
            drag.minimumY: 0
            drag.maximumX: Math.max(0, root.width - storeSurface.width)
            drag.maximumY: Math.max(0, root.height - storeSurface.height)
            onReleased: storeSurface.clampToScreen()
        }

        MaterialSymbol {
            anchors.top: parent.top
            anchors.right: closeButton.left
            anchors.topMargin: Metrics.margin("normal") + 8
            anchors.rightMargin: Metrics.margin("small")
            icon: "drag_indicator"
            iconSize: Metrics.iconSize(22)
            color: MaterialColors.colors.on_surface_variant
            z: 11
        }

        Store {
            anchors.fill: parent
        }

        StyledButton {
            id: closeButton

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Metrics.margin("normal")
            anchors.rightMargin: Metrics.margin("normal")
            icon: "close"
            text: ""
            secondary: true
            tooltipText: "Close store"
            onClicked: Globals.visiblility.storeOpen = false
        }
    }
}
