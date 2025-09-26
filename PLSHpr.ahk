/************************************************************************
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

#Include core\LockScreenMonitor.ahk
#include mods\BlackoutModule.ahk
#include mods\PreventLockModule.ahk
#Include mods\TopmostModule.ahk
#Include utils\Task.ahk
#Include utils\Debug.ahk

VERSION := "锁屏助手 v1.6.0"
A_IconTip := VERSION

Persistent
#SingleInstance Force

app := AppController()
app.InitTrayMenu()

;全局热键注册
+ESC:: app.ToggleBlackout() ;Shift+ESC
^+!A:: app.AddTopmost()  ;ctrl+shift+alt+A
^+!Z:: app.CancelTopmost()  ;ctrl+shift+alt+Z

class AppController {

    __new() {

        ;load services
        this.monitor := LockScreenMonitor()
        this.monitor.OnScreenLockedCallback := ObjBindMethod(this, 'Event_OnScreenLocked')

        ;load mods
        this.mods := {}
        this.mods.PreventLock := PreventLockModule()
        this.mods.Blackout := BlackoutModule()
        this.mods.Topmost := TopmostModule()
        this.mods.Topmost.OnSetTopmostCallback := ObjBindMethod(this, 'Event_OnSetTopmost')
        this.mods.Topmost.OnCancelTopmostCallback := ObjBindMethod(this, 'Event_OnCancelTopmost')
    }

    /** @description 修改托盘菜单，删除默认选项，增加功能选项和回调
     */
    InitTrayMenu() {
        this.tray := A_TrayMenu
        this.tray.Delete
        this.tray.add(VERSION, (*) => {})
        this.tray.Disable(VERSION)
        this.tray.add   ;seperator

        this.tray.Add("防止自动锁屏", (*) => this.TogglePreventLock())
        this.tray.Add("黑屏 Shift+ESC", (*) => this.ToggleBlackout())
        this.tray.add   ;seperator

        ;设置置顶窗口模块菜单
        this.tray.topmost := Menu()
        this.tray.add('当前置顶窗口', this.tray.topmost)

        this.tray.add   ;seperator
        this.tray.add("停用热键", (*) => this.ToggleSuspend())
        this.tray.Add("退出", (*) => ExitApp())

        TrayTip "后台待命中`r`n使用托盘菜单右键操作", "锁屏助手", 1
        DebugLog A_ThisFunc, '托盘功能初始化完成...'
    }

    /** @description 切换防止自动锁屏功能开关 */
    TogglePreventLock(*) {
        this.mods.PreventLock.toggle()
        this.tray.ToggleCheck('3&')
        if this.mods.PreventLock.enabled {
            this.monitor.Start()
            TrayTip("自动锁屏已禁用", "注意", 1)
            SetTimer(() => TrayTip(), -2000)
        }
        else {
            this.monitor.Stop()
            TrayTip("自动锁屏已恢复", "注意", 1)
            SetTimer(() => TrayTip(), -2000)
        }
    }

    /** @description 切换黑屏遮罩功能开关 */
    ToggleBlackout(*) {
        if !this.mods.blackout.enabled
            this.mods.blackout.Enable()
        else
            this.mods.blackout.Disable()

        this.tray.ToggleCheck('黑屏 Shift+ESC')
        return
    }

    /** @description 切换停用热键功能开关 */
    ToggleSuspend(*) {
        TraySetIcon(, , 1)    ;freeze icon
        Suspend(-1)
        this.tray.ToggleCheck("停用热键")
    }

    /** 置顶当前活动窗口 */
    AddTopmost() {
        this.mods.Topmost.SetTopmost('A')
    }

    CancelTopmost() {
        this.mods.Topmost.CancelTopmost()
    }

    ;----------------
    ;events callback
    ;----------------

    /** 锁屏事件回调方法 */
    Event_OnScreenLocked(*) { ;如果不设置任意入参*，则回调方法就不能正确的定位到AppController类，不知原理是什么
        if this.mods.PreventLock.enabled {
            this.TogglePreventLock()
            this.monitor.Stop()
        }
    }

    /** 设置窗口置顶回调方法 */
    Event_OnSetTopmost(obj, winTitle) {
        this.tray.topmost.add(wintitle, objBindMethod(this.mods.topmost, 'CancelTopMost', winTitle))
        TrayTip(winTitle "已置顶", "提示", 1)
        SetTimer(() => TrayTip(), -2000)

    }

    /** 取消窗口置顶回调方法 */
    Event_OnCancelTopmost(obj, winTitle) {
        this.tray.topmost.delete(wintitle)
        ;TrayTip(winTitle "已取消置顶", "提示", 1)
        ;SetTimer(() => TrayTip(), -2000)

    }
}
