pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Fallback stub for builds where Quickshell.Services.Polkit is unavailable.
    // Keeps the shell running; polkit prompt UI stays inactive.
    property bool isActive: false
    property bool isRegistered: false
    property string path: ""
    property QtObject flow: QtObject {
        property string message: ""
        property string inputPrompt: ""
        property bool failed: false
        property bool isSuccessful: false
        property bool isCompleted: false
        property bool isCancelled: true
        function cancelAuthenticationRequest() {}
        function submit(_input) {}
    }
}
