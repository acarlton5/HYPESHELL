import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

Item {
    anchors.fill: parent

    function openPage(index) {
        if (index < 0 || index >= view.count)
            return
        view.currentIndex = index
    }

    function openWallpapers() {
        Globals.states.sidebarLeftPage = 1
        openPage(1)
    }

    SwipeView {
        id: view

        anchors.fill: parent
        currentIndex: Globals.states.sidebarLeftPage
        onCurrentIndexChanged: Globals.states.sidebarLeftPage = currentIndex

        Repeater {
            model: ModuleManager.leftSidebarPages
            delegate: Loader {
                width: view.width
                height: view.height
                sourceComponent: modelData.content === "GadgetStage" ? gadgetStageComp : null
                source: modelData.content !== "GadgetStage" ? Qt.resolvedUrl("./" + modelData.content + ".qml") : ""
            }
        }
    }

    Component {
        id: gadgetStageComp
        GadgetStage { side: "left" }
    }

    Rectangle {
        height: 2
        width: parent.width - Metrics.margin("verylarge")
        color: Appearance.m3colors.m3outlineVariant
        opacity: 0.6

        anchors {
            top: view.top
            topMargin: segmentedIndicator.height + Metrics.margin("verysmall")
            horizontalCenter: view.horizontalCenter
        }

    }

    Rectangle {
        id: activeTabIndicator

        height: 2
        width: 96
        radius: Metrics.radius(1)
        color: Appearance.m3colors.m3primary
        x: (segmentedIndicator.width / view.count) * view.currentIndex + (segmentedIndicator.width / view.count - width) / 2

        anchors {
            top: segmentedIndicator.bottom
            topMargin: Metrics.margin(8)
        }

        Behavior on x {
            NumberAnimation {
                duration: Metrics.chronoDuration(220)
                easing.type: Easing.OutCubic
            }

        }

    }

    Item {
        id: segmentedIndicator

        height: 44
        width: parent.width

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: ModuleManager.leftSidebarPages

                Item {
                    width: segmentedIndicator.width / Math.max(1, view.count)
                    height: parent.height

                    MouseArea {
                        anchors.fill: parent
                        onClicked: view.currentIndex = index
                    }

                    // Icon (true center)
                    MaterialSymbol {
                        icon: modelData.icon
                        iconSize: Metrics.iconSize("huge")
                        color: view.currentIndex === index ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSurfaceVariant

                        anchors {
                            centerIn: parent
                        }

                    }

                }

            }

        }

    }

}
