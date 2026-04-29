import QtQuick
pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell

Singleton {
    id: root
    property QtObject visiblility
    property QtObject states

    visiblility: QtObject {
        property bool powermenu: false
        property bool launcher: false
        property bool sidebarRight: false
        property bool sidebarLeft: false
        property bool sidebarDev: false
        property bool dssFullPanelOpen: false
        property bool storeOpen: false
    }

    states: QtObject {
        property bool settingsOpen: false
        property int sidebarLeftPage: 0
    }

}
