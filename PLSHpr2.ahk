#requires AutoHotkey v2.0+

#Include AutoInclude.ahk

VERSION := "锁屏助手 v2.0.0"

Persistent
#SingleInstance Force

app := AppController()

class AppController {

    __new() {
        ;interfaces

        ; 模块接口
        this.IApp := AppInterface(this)
        ; 热键管理接口
        this.IHotkey := HotkeyController()
        ; 托盘菜单管理接口
        this.ITray := TrayMenuController(VERSION)
        ; 设置管理接口
        this.IConfig := ConfigController()

        ;加载的模块
        this.mods := {}

        ;加载的服务
        this.services := {}

    }
    InjectAppInterface() {
        for , mod in this.mods {
            if !mod.HasInterface()
                mod.SetAppInterface(this.IApp)
        }
        for , svc in this.services {
            if !svc.HasInterface()
                svc.SetAppInterface(this.IApp)
        }
    }
}
