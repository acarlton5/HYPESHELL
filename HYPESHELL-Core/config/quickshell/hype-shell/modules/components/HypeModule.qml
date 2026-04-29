import QtQuick
import Quickshell
import qs.config

Item {
    id: root
    property string moduleId: ""
    property string moduleName: ""
    property bool isLoaded: loader.status === Loader.Ready
    property bool hasError: loader.status === Loader.Error

    property alias source: loader.source
    property alias sourceComponent: loader.sourceComponent
    property alias item: loader.item

    Loader {
        id: loader
        anchors.fill: parent
        asynchronous: true
        
        onStatusChanged: {
            if (status === Loader.Error) {
                console.error(`[HypeShell] Failed to load module: ${root.moduleName} (${root.moduleId})`);
                console.error(`[HypeShell] Error: ${loader.source}`);
            }
        }
    }

    // Error Placeholder
    Rectangle {
        anchors.fill: parent
        visible: root.hasError
        color: "#aa0000"
        opacity: 0.8
        radius: 8
        border.color: "#ff0000"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: "⚠️"
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: root.moduleName || "Module Error"
                color: "white"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
