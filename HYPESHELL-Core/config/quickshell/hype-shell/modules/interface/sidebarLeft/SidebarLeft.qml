import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.services
import qs.modules.functions
import qs.modules.components

PanelWindow {
    id: sidebarLeft

    property real sidebarLeftWidth: 500

    function togglesidebarLeft() {
        Globals.visiblility.sidebarLeft = !Globals.visiblility.sidebarLeft;
    }

    WlrLayershell.namespace: "hype:sidebarLeft"
    WlrLayershell.layer: WlrLayer.Top
    visible: Config.initialized && Globals.visiblility.sidebarLeft && !Globals.visiblility.sidebarRight && !Globals.visiblility.sidebarDev
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: sidebarLeftWidth
    WlrLayershell.keyboardFocus: Compositor.require("niri") && Globals.visiblility.sidebarLeft

    HyprlandFocusGrab {
        id: grab

        active: Compositor.require("hyprland")
        windows: [sidebarLeft]
    }

    anchors {
        top: true
        left: (Config.runtime.bar.position === "left" || Config.runtime.bar.position === "bottom" || Config.runtime.bar.position === "top")
        bottom: true
        right: (Config.runtime.bar.position === "right")
    }

    margins {
        top: 0
        bottom: 0
        right: 0
        left: 0
    }

    StyledRect {
        id: container
        anchors.fill: parent
        anchors.margins: Metrics.margin("small")

        // Force a darker, near-opaque surface so desktop content does not show through.
        color: ColorUtils.applyAlpha(
            ColorUtils.mix(Appearance.m3colors.m3background, "#000000", 0.35),
            0.98
        )
        radius: Metrics.radius("normal")
        implicitWidth: sidebarLeft.sidebarLeftWidth

        FocusScope {
            focus: true 
            anchors.fill: parent

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    Globals.visiblility.sidebarLeft = false;
                }
            }

            SidebarLeftContent {
                id: sidebarLeftContent
                width: 500
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
        }
    }

    IpcHandler {
        function toggle() {
            togglesidebarLeft();
        }

        function openWallpapers() {
            HypeActions.openSidebarLeft("wallpapers")
        }

        target: "sidebarLeft"
    }
}
