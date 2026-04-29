import QtQuick
import QtQuick.Controls
import Appearance 1.0

Item {
    id: root
    width: 60
    height: 32

    property bool checked: Appearance.darkMode

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Appearance.colors.colLayer1Active : Appearance.colors.colLayer1
        border.color: Appearance.colors.colOutline
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        id: handle
        width: 24
        height: 24
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 4 : 4
        color: root.checked ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1

        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutExpo } }
        Behavior on color { ColorAnimation { duration: 200 } }

        Text {
            anchors.centerIn: parent
            text: root.checked ? "🌙" : "☀️"
            font.pixelSize: 14
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Appearance.setDarkMode(!root.checked)
        }
    }
}
