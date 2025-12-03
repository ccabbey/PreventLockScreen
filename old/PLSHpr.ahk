#requires AutoHotkey v2.0+

#Include core\LockScreenMonitor.ahk
#Include core\IdleTimeMonitor.ahk
#include mods\BlackoutModule.ahk
#include mods\PreventLockModule.ahk
#Include mods\TopmostModule.ahk
#Include utils\Task.ahk
#Include utils\Debug.ahk

VERSION := "锁屏助手 v1.6.5"
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
        this.services := {}
        this.services.lockscreenMonitor := LockScreenMonitor()
        this.services.lockscreenMonitor.OnScreenLockedCallback := ObjBindMethod(this, 'Event_OnScreenLocked')

        this.services.idleMonitor := IdleTimeMonitor()
        this.services.idleMonitor.OnMaxIdleTimeReachedCallback := ObjBindMethod(this, 'Event_OnMaxIdleTimeReached')
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

        this.tray.blackout := Menu()
        this.tray.Blackout.add("设置目标显示器", ObjBindMethod(this.mods.blackout, "SetTargetMonitor"))
        this.tray.Add("黑屏 Shift+ESC", this.tray.blackout)
        this.tray.add   ;seperator

        ;设置置顶窗口模块菜单
        this.tray.topmost := Menu()
        this.tray.add('置顶窗口 Ctrl+Shift+Alt+A/Z', this.tray.topmost)

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
            ; 启动锁屏状态监视服务
            this.services.lockscreenMonitor.Start()
            ;启动闲置时间监视服务
            this.services.idleMonitor.Start()
            TrayTip("防锁屏功能已启用", "注意", 1)
            SetTimer(() => TrayTip(), -2000)
        }
        else {
            this.services.lockscreenMonitor.Stop()
            TrayTip("防锁屏功能已禁用", "注意", 1)
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
    ;;已确认此实现会导致锁屏后屏幕仍然周期性点亮，但具体原因不明，大概率是TogglePreventLock方法有某种bug
    ;Event_OnScreenLocked(*) { ;如果不设置任意入参*，则回调方法就不能正确的定位到AppController类，不知原理是什么
    ;    DebugLog A_ThisFunc, "收到锁屏事件通知"
    ;    if this.mods.PreventLock.enabled {
    ;        this.TogglePreventLock()
    ;        ;this.services.lockscreenMonitor.Stop()
    ;        DebugLog A_ThisFunc, "已执行锁屏后处理任务"
    ;    }
    ;}
    Event_OnScreenLocked(*) { ;如果不设置任意入参*，则回调方法就不能正确的定位到AppController类，不知原理是什么
        DebugLog A_ThisFunc, "收到锁屏事件通知"
        if this.mods.PreventLock.enabled {
            this.mods.PreventLock.Disable
            this.services.lockscreenMonitor.Stop()
            if this.services.idleMonitor.running
                this.services.idleMonitor.Stop()
            this.tray.ToggleCheck('3&')
            DebugLog A_ThisFunc, "已执行锁屏后处理任务"
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

    Event_OnMaxIdleTimeReached(*) {
        DebugLog A_ThisFunc, "收到最大闲置时间触发通知"
        this.services.idleMonitor.Stop()
        if this.mods.PreventLock.enabled {
            this.mods.PreventLock.Disable()
            this.services.lockscreenMonitor.Stop()
            this.tray.ToggleCheck('3&')
            DebugLog A_ThisFunc, "由于达到了最大闲置时间限制，已自动取消防止锁屏功能和检测服务"
            MsgBox("由于达到了最大闲置时间限制，已自动取消防止锁屏功能和检测服务")
        }

    }

}
