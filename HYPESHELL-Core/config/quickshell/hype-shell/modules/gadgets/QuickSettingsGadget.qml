import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components
import "../interface/sidebarRight/content"

ColumnLayout {
    id: root
    spacing: Metrics.margin("large")
    Layout.fillWidth: true

    ColumnLayout {
        id: sliderColumn
        Layout.fillWidth: true

        VolumeSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            icon: "volume_up"
            iconSize: Metrics.iconSize("large") + 3
        }

        BrightnessSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            icon: "brightness_high"
        }
    }

    GridLayout {
        id: middleGrid
        Layout.fillWidth: true
        columns: 1
        columnSpacing: Metrics.spacing(8)
        rowSpacing: Metrics.spacing(8)

        RowLayout {
            NetworkToggle { Layout.fillWidth: true; Layout.preferredHeight: 80 }
            FlightModeToggle { Layout.fillWidth: true; Layout.preferredHeight: 80 }
        }

        RowLayout {
            BluetoothToggle { Layout.fillWidth: true; Layout.preferredHeight: 80 }
            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                active: Config.runtime.modules.dssWorkspace && Config.runtime.modules.dssWorkspace.enabled
                visible: active
                source: "file://" + Directories.shellConfig + "/modules/dss-systems/DssLauncher.qml"
            }
        }
    }

    NotifModal {
        Layout.fillWidth: true
        Layout.preferredHeight: 400
    }
}
