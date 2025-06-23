/************************************************************************
 * @description 
 * @author 
 * @date 2025/06/23
 * @version 1.3.0
 *  - 修复: 切换停用热键时，托盘选项不会打勾的问题
 *  - 修复: v1.2.1版本中用户锁定电脑后，程序无法正确关闭禁用锁屏功能。
 *  - 优化: 重构主要逻辑，解耦。重写了Blackout功能块。现在无需单独引用blackout.ahk了。
 * @version 1.2.1
 *  - 优化：如果用户主动锁定了电脑，禁用锁屏功能会自动关闭。否则电脑屏幕息屏后仍然会被定时器唤醒。

***********************************************************************/


#requires AutoHotkey v2.0

VERSION:= "锁屏助手 v1.3.0"
A_IconTip:= VERSION

Persistent


ctl:=TrayMenuController()
ctl.InitTrayMenu()
TrayTip  "后台待命中`r`n使用托盘菜单右键操作","锁屏助手",  1
SetTimer ()=> TrayTip(), -2000

+ESC:: ctl.ToggleBlackout() 

class TrayMenuController{

    __new(){
        this.PreventLock_On:=false
        this.Blackout_On:=false
        this.tray:=A_TrayMenu

        this.cloaks:=[]

        ; 此处需要先保存一个moveCursor的回调对象，以保证将来SetTimer在同一个回调上操作
        this.MoveCursorCallback := (*) => this.MoveCursor()
        this.CheckLockScreenStateCallback:=(*) => this.CheckLockScreenState()
    }

    /** @description 切换防止自动锁屏功能开关 */
    TogglePreventLock(*){
        this.PreventLock_On:=!this.PreventLock_On
        OutputDebug A_ThisFunc ': 切换功能开关 PreventLock_On = ' this.PreventLock_On
        if this.PreventLock_On{
            SetTimer(this.moveCursorCallback, 60000) ;def:60000
            this.tray.ToggleCheck('防止自动锁屏')
            TrayTip("自动锁屏已禁用","注意",  1)
            SetTimer(()=> TrayTip(), -2000)
            ; 同时开始监视锁屏状态，如果用户主动锁屏则恢复自动锁屏
            SetTimer(this.CheckLockScreenStateCallback,1000)
        }
        else{
            SetTimer(this.moveCursorCallback, 0)
            this.tray.ToggleCheck('防止自动锁屏')
            TrayTip("自动锁屏已恢复","注意",  1)
            SetTimer(()=> TrayTip(), -2000)
        }
    }

    ; 抖动鼠标
    MoveCursor() {
        MouseMove  1, 0, 1, 'R'  ;Move the mouse one pixel to the right
        MouseMove  -1, 0, 1, 'R' ;Move the mouse back one pixel
        OutputDebug A_ThisFunc ': 执行鼠标抖动操作...'
    }

    /** @description 修改托盘菜单，删除默认选项，增加功能选项和回调
     */
    InitTrayMenu(){
        this.tray.Delete
        this.tray.add(VERSION,(*)=>{})
        this.tray.Disable(VERSION)
        this.tray.add   ;seperator
        this.tray.Add("防止自动锁屏", (*)=>this.TogglePreventLock())
        this.tray.Add("黑屏 Shift+ESC", (*)=>this.ToggleBlackout())
        this.tray.add   ;seperator
        this.tray.add("停用热键",(*)=>this.ToggleSuspend())
        this.tray.Add("退出", (*)=>ExitApp())
    }

    /** @description 检查锁屏状态。如果用户锁定了屏幕，防止锁屏功能将自动关闭。 */
    CheckLockScreenState(){
        if IsScreenLocked(){
            OutputDebug A_ThisFunc ': 用户锁定了屏幕，恢复自动锁屏...'
            ; 取消caller设置的定时器
            settimer , 0
            ; 由于运行到此的前提是用户已经启用了防止锁屏，所以只要在执行一次TogglePreventLock即可关闭
            this.TogglePreventLock
            return
        }

        IsScreenLocked() {
        if h := DllCall("User32\OpenInputDesktop","int",0,"int",0,"int",1,"ptr")
            return false
        DllCall("User32\CloseDesktop","ptr",h)
        return true
        }   
    }

    /** @description 切换黑屏遮罩功能开关 */
    ToggleBlackout(*){
        this.Blackout_On:=!this.Blackout_On
        if this.Blackout_On{
            loop MonitorGetCount(){                                     ; Loop once for each monitor
                MonitorGet(A_Index, &l, &t, &r, &b)                     ; Get left, top, right, and bottom coords
                this.cloaks.Push(make_black_overlay(l, t, r, b))   ; Make a black GUI using coord then add to list
            }
        }
        else{
            if (this.cloaks.Length > 0) {                              ; If guis are present
                for _, cloak in this.cloaks                              ; Loop through the list
                    cloak.Destroy()                                   ; And destroy each one
            this.cloaks := []                                      ; Clear gui list          
            }  
        }
        this.tray.ToggleCheck('黑屏 Shift+ESC')
        return

        /** @description 在所有显示器上绘制黑色遮罩 */
        make_black_overlay(l, t, r, b) {                        ; Nested function to make guis
            x := l, y := t, w := Abs(l+r), h := Abs(t+b)        ; Set x y width height using LTRB
            ,cloak := Gui('+AlwaysOnTop -Caption -DPIScale')      ; Make gui with no window border
            ,cloak.BackColor := 0x0                               ; Make it black
            ,cloak.Show()                                         ; Show it
            ,cloak.Move(x, y, w, h)                               ; Resize it to fill the monitor
            return cloak                                          ; Return gui object
        }
    }

    /** @description 切换停用热键功能开关 */
    ToggleSuspend(*) {
        TraySetIcon(,,1)    ;freeze icon
        Suspend(-1)
        this.tray.ToggleCheck("停用热键")
    }
    
}




