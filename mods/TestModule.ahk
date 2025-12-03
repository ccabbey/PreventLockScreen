#Requires AutoHotkey v2.0

#Include ModuleBase.ahk
#Include ..\utils\Debug.ahk

class TestModule extends ModuleBase {
    __new() {
        super.__new()
    }

    Enable() {
        super.Enable()
    }

    OnEnabled() {
        Log '子类的OnEnable方法'
    }
}

m := TestModule()
m.Enable()
m.Disable()