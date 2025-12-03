#Requires AutoHotkey v2.0

;#Include ..\AutoInclude.ahk
#Include ..\utils\Debug.ahk

class ModuleBase {

    __new() {
        this.moduleName := this.__Class
        ; AppInterface
        this.IApp := unset
        ; 模块启用状态Flag
        this.Enabled := false
    }

    ; 注入AppInterface
    SetAppInterface(interface) {
        this.IApp := interface
    }
    ; 基础方法，业务逻辑应在OnEnabled()中实现
    Enable() {
        if !this.Enabled {
            this.OnEnabled()
            this.Enabled := true
            Log this.moduleName ' 模块已启用'
        }
    }

    OnEnabled() {
        throw Error('子类必须实现OnEnabled方法')
    }

    Disable() {
        if (this.enabled) {
            this.enabled := false
            if this.HasMethod('OnEnabled')
                this.OnEnabled()
            Log this.moduleName ' 模块已禁用'
        }
    }

    Toggle() {
        if this.enabled
            this.Disable()
        else
            this.Enable()
    }
}
