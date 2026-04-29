pragma Singleton
import QtQuick
import Quickshell
import qs.config
import qs.services

Singleton {
    id: root

    // Centralized Navigation
    function openSidebarLeft(pageId = "") {
        Globals.visiblility.sidebarRight = false;
        Globals.visiblility.sidebarDev = false;
        Globals.visiblility.sidebarLeft = true;
        
        if (pageId !== "") {
            const idx = ModuleManager.leftSidebarPages.findIndex(p => p.id === pageId);
            if (idx !== -1) Globals.states.sidebarLeftPage = idx;
        }
    }

    function openSidebarRight(pageId = "") {
        Globals.visiblility.sidebarLeft = false;
        Globals.visiblility.sidebarDev = false;
        Globals.visiblility.sidebarRight = true;
        
        if (pageId !== "") {
            const idx = ModuleManager.rightSidebarPages.findIndex(p => p.id === pageId);
            if (idx !== -1) Globals.states.sidebarRightPage = idx;
        }
    }

    function toggleSettings() {
        Globals.states.settingsOpen = !Globals.states.settingsOpen;
    }

    // Specialized Actions
    function changeWallpaper() {
        openSidebarLeft("appearance");
    }

    function applyThemeMode(mode) {
        const desired = String(mode || "").trim().toLowerCase();
        if (desired !== "light" && desired !== "dark") return;
        
        console.log("[HypeActions] Setting theme mode: " + desired);
        Quickshell.execDetached(["hype", "ipc", "call", "global", "setTheme", desired]);
    }

    // Update Logic (Centralized)
    function runUpdate() {
        console.log("[HypeActions] Starting update...");
        Quickshell.execDetached(["notify-send", "Hype Shell", "Starting one-click update..."]);
        Quickshell.execDetached(["bash", "-c", "curl -fsSL https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-Installer/install.sh | bash"]);
    }

    function refreshUpdateStatus() {
        console.log("[HypeActions] Manual refresh requested.");
        if (UpdateService) UpdateService.checkForUpdates();
    }
}
