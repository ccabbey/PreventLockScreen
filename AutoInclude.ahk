#Requires AutoHotkey v2.0

; utils
#Include utils\Task.ahk
#Include utils\Debug.ahk

; core components
#Include core\TrayMenuController.ahk
#Include core\HotkeyController.ahk
#Include core\ConfigController.ahk
#Include core\AppInterface.ahk

; modules
#include mods\BlackoutModule.ahk
#include mods\PreventLockModule.ahk
#Include mods\TopmostModule.ahk

; services
#Include services\LockScreenMonitor.ahk
#Include services\IdleTimeMonitor.ahk