#Requires AutoHotkey v2.0

class HotkeyController {
    __new() {
        this.hotkeys := []
    }
    SetHotkey(keycomb, func) {
        Hotkey(keycomb, func)
        this.hotkeys.Push keycomb
    }
}
