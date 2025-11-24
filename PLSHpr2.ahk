/************************************************************************
 * @version v1.7.0 @2025/11/25
 *  - 优化: 重构PLSHpr.ahk，提供多种接口
 * @version v1.6.3 @2025/11/20
 *  - 优化: 托盘菜单新增选项，黑屏遮罩功能可以指定所有显示器或某个单独的显示器
 * @version v1.6.2 @2025/11/18
 *  - 优化: 内置了一个最大闲置时间120min的限制，防止用户忘记关闭防锁屏功能导致屏幕长时间点亮 
 * @version v1.6.1 @2025/9/26
 *  - 修复: 修复了锁屏后屏幕仍然定时被唤醒的错误 
 * @version v1.6.0 @2025/9/15
 *  - 优化: 重构了程序框架，主要功能模块化
 *  - 功能: 移除了智能恢复功能
 *  - 功能: 窗口置顶功能改为最多只能置顶1个窗口。置顶新窗口将自动取消旧窗口的置顶状态。
 *  - TODO: 添加配置文件并实现功能模块的启用/禁用
 * @version 1.5.0 @2025/07/04
 *  - 功能: 增加置顶活动窗口的功能
 * @version 1.4.0 @2025/06/23
 *  - 优化: 用户手动锁屏并重登录后，防止锁屏功能将恢复锁屏前的状态
 * @version 1.3.0 @2025/06/23
 *  - 修复: 切换停用热键时，托盘选项不会打勾的问题
 *  - 修复: v1.2.1版本中用户锁定电脑后，程序无法正确关闭禁用锁屏功能。
 *  - 优化: 重构主要逻辑，解耦。重写了Blackout功能块。现在无需单独引用blackout.ahk了。
 * @version 1.2.1
 *  - 优化：如果用户主动锁定了电脑，禁用锁屏功能会自动关闭。否则电脑屏幕息屏后仍然会被定时器唤醒。
 * 
 ***********************************************************************/

#requires AutoHotkey v2.0+

#include core\TrayMenuController.ahk
#Include services\LockScreenMonitor.ahk
#Include services\IdleTimeMonitor.ahk
#include mods\BlackoutModule.ahk
#include mods\PreventLockModule.ahk
#Include mods\TopmostModule.ahk
#Include utils\Task.ahk
#Include utils\Debug.ahk

VERSION := "锁屏助手 v1.6.3"
A_IconTip := VERSION

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
    }
}

class AppInterface {

    __new(appController) {
        this.app := appController
    }

    UseTrayMenu() {
        return this.app.ITray
    }

    UseHotkey() {
        return this.app.IHotkey
    }

    UseConfig() {
        return this.app.IConfig
    }

    UseModule(moduleName) {
        if (this.app.mods.HasProp(moduleName)) {
            return this.app.mods.%moduleName%
        }
        return unset
    }
}

class HotkeyController {
    __new() {
        this.hotkeys := []
    }
    SetHotkey(keycomb, func) {
        Hotkey(keycomb, func)
        this.hotkeys.Push keycomb
    }
}

class ConfigController {

    __new() {
        this.DirPath := A_AppData '\PLSHpr\'
        this.ConfigFile := this.DirPath 'PLSHpr.ini'
        ;检查配置文件是否存在
        if !DirExist(this.DirPath)
            DirCreate(this.DirPath)
        if !FileExist(this.ConfigFile) {
            content := "[IdleTimeMonitor]`n"
            content .= 'MaxIdleTime = 120'
            FileAppend(content, this.ConfigFile)
        }
    }

    GetConfigValue(module, key) {
        return IniRead(this.ConfigFile, module, key)
    }

}
