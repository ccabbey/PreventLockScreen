#Requires AutoHotkey v2.0

#Include ..\utils\Task.ahk
#Include ..\utils\Debug.ahk

class ModuleBase {
    appInterface := unset
    moduleName := ''

    __new() {
        this.moduleName := this.__Class
    }

    SetAppInterface(interface) {
        this.appInterface := interface
    }

    HasInterface() {
        return IsSet(this.appInterface)
    }

    UseTrayMenu() {
        if (this.HasInterface()) {
            return this.appInterface.UseTrayMenu()
        }
        return unset
    }

    UseHotkey() {
        if (this.HasInterface()) {
            return this.appInterface.UseHotkey()
        }
        return unset
    }

    UseModule(moduleName) {
        if (this.HasInterface()) {
            return this.appInterface.HasModule(moduleName) ? this.appInterface.UseModule(moduleName) : unset
        }
        return unset
    }

    UseService(serviceName) {
        if (this.HasInterface()) {
            return this.appInterface.UseService(serviceName)
        }
        return unset
    }
}
