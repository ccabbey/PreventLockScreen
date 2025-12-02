#Requires AutoHotkey v2.0

#Include ..\utils\Task.ahk
#Include ..\utils\Debug.ahk

; 服务基类，提供主模块和定时任务的接口
class ServiceBase {

    __new() {
        this.appInterface := unset
        this.serviceName := this.__Class
        this.monitorTask :=
    }

    ;===TaskRoutine Interfaces===
    Start() {

    }

    Stop() {

    }

    ;===AppInterface Interfaces===

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
    UseConfig() {
        if (this.HasInterface()) {
            return this.appInterface.UseConfig()
        }
        return unset
    }

}
