/************************************************************************
 * @description 
 * @author 
 * @date 2025/06/20
 * @version 1.2.1
 *  - 优化：如果用户主动锁定了电脑，禁用锁屏功能会自动关闭。否则电脑屏幕息屏后仍然会被定时器唤醒。
 ***********************************************************************/


#requires AutoHotkey v2.0

#Include "blackout.ahk"

VERSION:= "锁屏助手 v1.2.1"
A_IconTip:= VERSION


;global flags

;黑屏功能开关
global blackout_on:= false
;锁屏功能开关
global preventLock_on:=false

;splash screen
TrayTip  "后台待命中`r`n使用托盘菜单右键操作","锁屏助手",  1
SetTimer ()=> TrayTip(), -5000



;;;
;Core functions
;;;

;通过定时移动光标来防止屏幕保护程序启动
PreventLock() {
    global preventLock_on
    ; disable prevent lock function if detect user manully locked the screen
    if IsScreenLocked && preventLock_on{
        SetTimer MoveCursor, 0
        TrayTip  "由于用户主动锁定了电脑，自动锁屏已恢复","注意",  1
        SetTimer ()=> TrayTip(), -2000
        t.ToggleCheck("禁用锁屏")

    }
    preventLock_on:=!preventLock_on ; Toggle prevent lock state
    if (preventLock_on) {
        SetTimer MoveCursor, 60000 ; Screen-saver launch prevention label (subroutine), checks every 1 minute
    }
    else { 
        SetTimer MoveCursor, 0 ; Screen-saver launch prevention label (subroutine), checks every 1 minute
    }
    return

    ;光标抖动1个像素点
    MoveCursor() {
        MouseMove  1, 0, 1, 'R'  ;Move the mouse one pixel to the right
        MouseMove  -1, 0, 1, 'R' ;Move the mouse back one pixel
        return
    }
}   

BlackoutWrapper(*) {
    global blackout_on
    blackout_on:=!blackout_on ; Toggle blackout state
    blackout_on ? Blackout_Start(0):Blackout_Stop()
}

;;;
;tray menu customization
;;;
t:=A_TrayMenu
t.Delete 
t.add(VERSION,NoAction)
t.Disable(VERSION)
t.add   ;seperator

t.Add("禁用锁屏", TogglePreventLockOnly)
t.Add("黑屏 Shift+ESC", ToggleBlackoutOnly)
;t.Add("禁用锁屏+黑屏", TogglePreventLockAndBlackout)
t.add   ;seperator

t.add("停用热键",ToggleSuspendHotkeys)
t.Add("退出", ExitHandle)

;tray menu event handlers

;废弃
TogglePreventLockAndBlackout(*) {
    PreventLock
    BlackoutWrapper
    t.ToggleCheck("禁用锁屏+黑屏")
    t.ToggleEnable("禁用锁屏")
    t.ToggleEnable("黑屏")
    MsgBox "preventLock="  preventLock_on
    MsgBox "blackout=" blackout_on
}

TogglePreventLockOnly(*) {
    global preventLock_on
    PreventLock
    if (preventLock_on) {
        TrayTip  "自动锁屏已禁用","注意",  1
        SetTimer ()=> TrayTip(), -2000
    }
    else { 
        TrayTip  "自动锁屏已恢复","注意",  1
        SetTimer ()=> TrayTip(), -2000
    }
    t.ToggleCheck("禁用锁屏")
}

ToggleBlackoutOnly(*) {
     BlackoutWrapper
     t.ToggleCheck("黑屏 Shift+ESC")
}

ToggleSuspendHotkeys(*) {
    TraySetIcon(,,1)    ;freeze icon
    Suspend(-1)
    t.ToggleCheck("停用热键")
}

ExitHandle(*) {
    ExitApp
}

NoAction(*) {
    ; Do nothing
}

;hotkey section

+ESC:: {    ;Shift+ESC to toggle blackout
    ToggleBlackoutOnly()
}

IsScreenLocked() {
	if h := DllCall("User32\OpenInputDesktop","int",0,"int",0,"int",1,"ptr")
		return false
	DllCall("User32\CloseDesktop","ptr",h)
	return true
}