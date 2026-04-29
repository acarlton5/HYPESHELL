/**
 * dss-panel.qml — Standalone DSS WebEngine panel.
 *
 * Launched by DssFullPanel.qml via qml6 (not Quickshell).
 * qml6 properly initialises QtWebEngine before QApplication,
 * so WebEngineView works without Quickshell's init restriction.
 *
 * Usage: qml6 --platform wayland dss-panel.qml --urlarg <url>
 * The URL is read from the DSS_URL environment variable.
 *
 * Hyprland window rules match class "org.qt-project.qml".
 * Close with Super+Shift+D (IPC closePanel) or Alt+F4.
 */

import QtQuick
import QtQuick.Window
import QtWebEngine

Window {
    id: root

    Component.onCompleted: {
        Qt.application.name = "DSS Systems"
        Qt.application.organization = "DSS-System"
    }

    property string targetUrl: Qt.application.arguments.length > 1
        ? Qt.application.arguments[Qt.application.arguments.length - 2]
        : "about:blank"

    property string adminToken: Qt.application.arguments.length > 0
        ? Qt.application.arguments[Qt.application.arguments.length - 1]
        : ""

    visible:    true
    visibility: Window.FullScreen
    title:      "DSS Systems Panel"
    color:      "#000000"

    WebEngineProfile {
        id: dssProfile
        storageName: "DSSSystemsV1"
        persistentStoragePath: "/home/morph/.dss-systems/webengine"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        httpCacheType: WebEngineProfile.DiskHttpCache
        offTheRecord: false
    }

    WebEngineView {
        anchors.fill: parent
        url: root.targetUrl
        profile: dssProfile

        onLoadingChanged: (loadRequest) => {
            if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(`
                    window.DSS_CONFIG = window.DSS_CONFIG || {};
                    window.DSS_CONFIG.GITEA_TOKEN_ADMIN = "${root.adminToken}";
                `)
            }
        }

        settings.javascriptEnabled:          true
        settings.localContentCanAccessRemoteUrls: true
        settings.localStorageEnabled:        true
        settings.allowRunningInsecureContent: true
    }
}
