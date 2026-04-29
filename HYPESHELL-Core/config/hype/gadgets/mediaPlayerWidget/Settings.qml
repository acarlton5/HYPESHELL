import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components

ColumnLayout {
    spacing: Metrics.spacing(8)

    StyledSwitchOption {
        title: "Desktop Gadget"
        description: "Enable or disable the media player desktop gadget."
        prefField: "plugins.mediaPlayer.enabled"
    }

    StyledSwitchOption {
        title: "Show in System Bar"
        description: "Show media controls in the top system bar."
        prefField: "plugins.mediaPlayer.showInBar"
    }

    StyledSwitchOption {
        title: "Enable Peek Function"
        description: "Show the gadget briefly when media status changes."
        prefField: "plugins.mediaPlayer.peekEnabled"
    }

    NumberStepper {
        label: "Peek Duration (ms)"
        description: "How long the gadget stays visible during a peek."
        prefField: "plugins.mediaPlayer.peekDurationMs"
        minimum: 500
        maximum: 60000
        step: 250
    }
}
