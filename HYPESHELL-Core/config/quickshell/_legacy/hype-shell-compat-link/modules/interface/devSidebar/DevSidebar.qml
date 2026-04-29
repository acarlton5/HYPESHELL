import qs.config
import qs.modules.components
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: devSidebar

    property real panelWidth: 560

    WlrLayershell.namespace: "hype:sidebarDev"
    WlrLayershell.layer: WlrLayer.Top
    visible: Config.initialized
        && Globals.visiblility.sidebarDev
        && !Globals.visiblility.sidebarRight
        && !Globals.visiblility.sidebarLeft
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: Compositor.screenW
    WlrLayershell.keyboardFocus: Compositor.require("niri") && Globals.visiblility.sidebarDev

    HyprlandFocusGrab {
        active: Compositor.require("hyprland")
        windows: [devSidebar]
    }

    anchors {
        top: true
        right: (Config.runtime.bar.position === "top"
            || Config.runtime.bar.position === "bottom"
            || Config.runtime.bar.position === "right")
        bottom: true
        left: (Config.runtime.bar.position === "left")
    }

    margins {
        top: Config.runtime.bar.margins
        bottom: Config.runtime.bar.margins
        left: Metrics.margin("small")
        right: Metrics.margin("small")
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        onPressed: Globals.visiblility.sidebarDev = false
    }

    StyledRect {
        id: container
        z: 1
        color: Appearance.m3colors.m3background
        radius: Metrics.radius("large")
        width: devSidebar.panelWidth

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = true
        }

        FocusScope {
            focus: true
            anchors.fill: parent

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape)
                    Globals.visiblility.sidebarDev = false
            }

            Loader {
                anchors.fill: parent
                source: Qt.resolvedUrl("./DevSidebarContent.qml")
            }
        }
    }

    function toggleSidebarDev() {
        Globals.visiblility.sidebarRight = false
        Globals.visiblility.sidebarLeft = false
        Globals.visiblility.sidebarDev = !Globals.visiblility.sidebarDev
    }

    IpcHandler {
        target: "sidebarDev"
        function toggle() {
            toggleSidebarDev()
        }
    }
}
