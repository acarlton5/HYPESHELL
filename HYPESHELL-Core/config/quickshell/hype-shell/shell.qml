import Quickshell
import QtQuick 

import qs.config
import qs.plugins
import qs.services
import qs.modules.interface.bar
import qs.modules.interface.background
import qs.modules.interface.powermenu
import qs.modules.interface.launcher
import qs.modules.interface.notifications
import qs.modules.interface.overlays
import qs.modules.interface.sidebarRight
import qs.modules.interface.settings
import qs.modules.interface.store
import qs.modules.interface.sidebarLeft
import qs.modules.interface.lockscreen
import qs.modules.interface.screencapture
import qs.modules.interface.polkit

ShellRoot {
    id: shellroot 
    readonly property var _wallpaperSlideshow: WallpaperSlideshow
    readonly property var _updateService: UpdateService

    // Load modules

    LazyLoader {
        id: barLoader
        source: Contracts.bar
        active: Config.runtime.bar.enabled && !Contracts.overriddenBar
    }

    LazyLoader {
        id: backgroundLoader
        source: Contracts.background
        active: Config.runtime.appearance.background.enabled && !Contracts.overriddenBackground
    }

    LazyLoader {
        id: powerMenuLoader
        source: Contracts.powerMenu
        active: Globals.visiblility.powermenu && !Contracts.overriddenPowerMenu
    }

    LazyLoader {
        id: launcherLoader
        source: Contracts.launcher
        active: true && !Contracts.overriddenLauncher
    }

    LazyLoader {
        id: notificationsLoader
        source: Contracts.notifications
        active: Config.runtime.notifications.enabled && !Contracts.overriddenNotifications
    }

    LazyLoader {
        id: overlaysLoader
        source: Contracts.overlays
        active: Config.runtime.overlays.enabled && !Contracts.overriddenOverlays
    }

    LazyLoader {
        id: sidebarRightLoader
        source: Contracts.sidebarRight
        active: Globals.visiblility.sidebarRight && !Contracts.overriddenSidebarRight
    }

    LazyLoader {
        id: sidebarLeftLoader
        source: Contracts.sidebarLeft
        active: Globals.visiblility.sidebarLeft && !Contracts.overriddenSidebarLeft
    }

    LazyLoader {
        id: sidebarDevLoader
        source: "file://" + Directories.shellConfig + "/modules/dss-systems/DssSidebar.qml"
        active: Config.runtime.modules.dssSystems ? Config.runtime.modules.dssSystems.enabled : false
    }

    LazyLoader {
        id: lockScreenLoader
        source: Contracts.lockScreen
        active: true && !Contracts.overriddenLockScreen
    }

    LazyLoader {
        active: Globals.states.settingsOpen
        Settings { }
    }
    LazyLoader {
        active: Globals.visiblility.storeOpen
        StoreWindow { }
    }
    Ipc { }
    UpdateNotifier { }
    PluginHost { }
    ScreenCapture{ }
    PolkitAgent { }
}
