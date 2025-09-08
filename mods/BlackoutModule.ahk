#Requires AutoHotkey v2.0

class BlackoutModule {

    __new() {
        this.cloaks := []
        this.enabled := false
    }

    Enable() {
        if !this.enabled {
            loop MonitorGetCount() {                                     ; Loop once for each monitor
                MonitorGet(A_Index, &l, &t, &r, &b)                     ; Get left, top, right, and bottom coords
                this.cloaks.Push(this.makeCloak(l, t, r, b))   ; Make a black GUI using coord then add to list
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
}
