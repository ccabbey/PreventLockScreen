#Requires AutoHotkey v2.0

class TrayMenuController {
    __new(appVersion) {
        this.appVersion := appVersion
        this.tray := A_TrayMenu
        this.TrayMenuSetup()
        this.configMenu := Menu()
        this.tray.Add('设置', this.configMenu)
    }

    TrayMenuSetup() {
        this.tray.Delete
        this.tray.add(VERSION, (*) => {})
        this.tray.Disable(VERSION)
        this.tray.add   ;seperator
    }

    AddConfigMenuItem(itemName, callback) {
        this.configMenu.add(itemName, callback)
    }

    AddMenuItem(itemName, callback) {
        this.tray.add(itemName, callback)
    }

}
