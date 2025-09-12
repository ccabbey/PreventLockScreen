#Requires AutoHotkey v2.0

#Include ..\utils\Task.ahk

class PreventLockModule {

    __new() {
        /** 光标抖动任务 */
        this.cursorTask := Task(ObjBindMethod(this, 'MoveCursor'), 60000)  ; 默认30秒移动一次鼠标
        /** 模块启用状态Flag */
        this.enabled := false
    }

    /**启用防止锁屏功能 */
    Enable() {
        if !this.enabled {
            this.cursorTask.Start()
            this.enabled := true
        }
    }

    Disable() {
        if this.enabled {
            this.cursorTask.Stop()
            this.enabled := false
        }
    }

    Toggle() {
        if this.enabled
            this.Disable()
        else
            this.Enable()
    }

    MoveCursor() {
        MouseMove 1, 0, 1, 'R'   ; Move the mouse one pixel to the right
        MouseMove -1, 0, 1, 'R'  ; Move the mouse back one pixel
    }
}
