/************************************************************************
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

#Include utils\Task.ahk
#Include utils\Debug.ahk
#include mods\BlackoutModule.ahk
#include mods\PreventLockModule.ahk

VERSION := "锁屏助手 v1.6.0"
A_IconTip := VERSION

Persistent
#SingleInstance Force

app := AppController()
app.InitTrayMenu()

;全局热键注册
+ESC:: app.ToggleBlackout() ;Shift+ESC
^+!A:: app.ToggleTopmost()  ;ctrl+shift+alt+A

class AppController {

    __new() {
        this.flags := {}

        ;load mods
        this.mods := {}
        this.mods.PreventLock := PreventLockModule()
        this.mods.PreventLock.OnScreenLockedCallback := this.OnScreenLocked
        this.mods.PreventLock.OnScreenUnlockedCallback := this.OnScreenUnlocked

        this.mods.Blackout := BlackoutModule()

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
        this.tray.Add('置顶窗口 Ctrl+Shift+Alt+A', (*) => this.ToggleTopmost())
        this.tray.Disable('置顶窗口 Ctrl+Shift+Alt+A')
        this.tray.add   ;seperator
        this.tray.Add('智能恢复', (*) => this.ToggleAutoRecover())
        this.tray.add("停用热键", (*) => this.ToggleSuspend())
        this.tray.Add("退出", (*) => ExitApp())

        TrayTip "后台待命中`r`n使用托盘菜单右键操作", "锁屏助手", 1
        DebugLog A_ThisFunc, '托盘功能初始化完成...'
    }

    /** @description 切换防止自动锁屏功能开关 */
    TogglePreventLock(*) {
        this.mods.PreventLock.toggle()
        if this.mods.PreventLock.enabled {
            this.tray.ToggleCheck('3&') ;防止自动锁屏
            TrayTip("自动锁屏已禁用", "注意", 1)
            SetTimer(() => TrayTip(), -1000)
        }
        else {
            this.tray.ToggleCheck('3&') ;防止自动锁屏
            TrayTip("自动锁屏已恢复", "注意", 1)
            SetTimer(() => TrayTip(), -1000)
        }
    }

    ;PreventLockModule的事件回调注册

    OnScreenLocked() {
        this.TogglePreventLock()
    }
    OnScreenUnlocked() {
        this.TogglePreventLock()
    }

    /** @description 切换黑屏遮罩功能开关 */
    ToggleBlackout(*) {
        this.mods.blackout.enabled := this.mods.blackout.enabled
        if this.mods.blackout.enabled
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

    /** @description 切换智能恢复功能开关 */
    ToggleAutoRecover(*) {
        this.AutoRecover_On := !this.AutoRecover_On
        this.tray.ToggleCheck('智能恢复')
    }

    /**
     * 切换当前活动窗口的置顶状态。
     * @param {String} winTitle 需要切换置顶状态的窗口标题，默认为当前活动窗口。
     */
    ToggleTopmost(winTitle := 'A') {

        ;通过 WinGetExStyle 获取窗口的扩展样式，然后判断是否包含 WS_EX_TOPMOST（值为 0x00000008），来判断窗口是否为“置顶”状态
        try {
            winTitle := WinGetTitle(winTitle)
            if winTitle == 'Program Manager'  ; 桌面不能置顶
                return
        }
        catch {
            msgbox '请使用Ctcl+Shift+Alt+A组合键来切换窗口置顶。`r`n 点击菜单中的程序名称也可以取消置顶。', '提示'
            return
        }
        winName := WinGetProcessName(winTitle)
        exStyle := WinGetExStyle(winTitle)
        if (exStyle & 0x8 != 0) {    ; 0x8 即 WS_EX_TOPMOST
            WinSetAlwaysOnTop(0, winTitle)
            try
                this.tray.delete(winName)
            catch
                Sleep -1    ; 如果窗口在程序启动前已经置顶，那么就无Menu项可删
            TrayTip(winName '`r`n 已取消置顶')
            SetTimer(() => TrayTip(), -1000)
        }
        else {
            WinSetAlwaysOnTop(1, winTitle)
            this.tray.Insert('7&', winName, (*) => this.ToggleTopmost(winTitle))    ; 7&表示菜单从上向下第7个Item
            TrayTip(winName '`r`n 已置顶')
            SetTimer(() => TrayTip(), -1000)
        }
    }

}
