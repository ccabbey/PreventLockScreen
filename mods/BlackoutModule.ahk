#Requires AutoHotkey v2.0

class BlackoutModule {

    __new() {
        this.cloaks := []
        this.enabled := false
        this.targetMonitor := 0
    }

    Enable() {
        if !this.enabled {
            if this.targetMonitor == 0 {
                loop MonitorGetCount()
                    this.setMonitorCloak(A_Index)   ; Loop once for each monitor
            }
            else {
                try {
                    this.setMonitorCloak(this.targetMonitor)
                }
                catch {
                    ;targetMonitor不存在？
                    DebugLog A_ThisFunc, this.targetMonitor ' 号显示器似乎不存在，是否插拔了显示器接口？'
                }
            }
            this.enabled := true
        }
    }
    Disable() {
        if this.enabled {
            if (this.cloaks.Length > 0) {                              ; If guis are present
                for _, cloak in this.cloaks                              ; Loop through the list
                    cloak.Destroy()                                   ; And destroy each one
                this.cloaks := []                                      ; Clear gui list
            }
            this.enabled := false
        }
    }

    Toggle() {
        if this.enabled
            this.Disable()
        else
            this.Enable()
    }

    /** @description 在所有显示器上绘制黑色遮罩 */
    makeCloak(l, t, r, b) {                        ; Nested function to make guis
        x := l, y := t, w := Abs(l + r), h := Abs(t + b)        ; Set x y width height using LTRB
        , cloak := Gui('+AlwaysOnTop -Caption -DPIScale')      ; Make gui with no window border
        , cloak.BackColor := 0x0                               ; Make it black
        , cloak.Show()                                         ; Show it
        , cloak.Move(x, y, w, h)                               ; Resize it to fill the monitor
        return cloak                                          ; Return gui object
    }

    setMonitorCloak(index) {
        MonitorGet(index, &l, &t, &r, &b)                     ; Get left, top, right, and bottom coords
        this.cloaks.Push(this.makeCloak(l, t, r, b))   ; Make a black GUI using coord then add to list
    }

    SetTargetMonitor(*) {
        prompt := '当前显示器数: ' MonitorGetCount() '`r`n'
        prompt .= '设置目标显示器: ( 0 = 所有显示器, X = 仅 X 号显示器) '
        loop {
            param := InputBox(prompt, '黑屏功能设置', 'w350 h150', this.targetMonitor).Value
            if param <= MonitorGetCount() {
                this.targetMonitor := param
                break
            }
            else
                msgbox(param ' 号显示器不存在，当前只有 ' MonitorGetCount() ' 个显示器！')
        }
    }
}
