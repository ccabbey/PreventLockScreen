#Requires AutoHotkey v2.0

#Include ..\utils\Task.ahk

class PreventLockModule {
    ;event callback
    OnScreenLockedCallback := unset
    OnScreenUnlockedCallback := unset

    __new() {
        this.monitor := LockScreenMonitor()
        this.monitor.OnScreenLockedCallback := this.OnScreenLocked.Bind()
        this.monitor.OnScreenUnlockedCallback := this.OnScreenUnlocked.Bind()

        this.cursorTask := Task(ObjBindMethod(this, 'MoveCursor'), 60000)  ; 默认30秒移动一次鼠标
        this.enabled := false
        this.wasEnabledBeforeLock := false
        this.autoRecover := false
    }

    Enable() {
        if !this.enabled {
            this.cursorTask.Start()
            this.monitor.Start()
            this.enabled := true
            this.wasEnabledBeforeLock := true
        }
    }

    Disable() {
        if (this.enabled) {
            this.cursorTask.Stop()
            this.monitor.Stop()
            this.enabled := false
        }
    }

    Toggle() {
        if (this.enabled) {
            this.Disable()
        } else {
            this.Enable()
        }
    }

    IsEnabled() {
        return this.enabled
    }

    IsScreenLocked() {
        return this.monitor.IsCurrentlyLocked()
    }

    ; 事件处理方法
    OnScreenLocked() {
        if this.enabled {
            this.Disable()
            this.wasEnabledBeforeLock := true
        }
    }

    OnScreenUnlocked() {
        if (this.autoRecover && this.wasEnabledBeforeLock) {
            this.Enable()
            this.wasEnabledBeforeLock := false
        }
    }

    MoveCursor() {
        MouseMove 1, 0, 1, 'R'   ; Move the mouse one pixel to the right
        MouseMove -1, 0, 1, 'R'  ; Move the mouse back one pixel
    }
}

class LockScreenMonitor {
    ;event callback
    OnScreenLockedCallback := unset
    OnScreenUnlockedCallback := unset

    __new() {
        this.monitorTask := Task(ObjBindMethod(this, 'MonitorTaskRoutine'), 1000)
        this.isLocked := false
    }

    Start() {
        this.monitorTask.Start()
    }

    Stop() {
        this.monitorTask.Stop()
    }

    IsCurrentlyLocked() {
        return this.CheckLockScreen()
    }

    MonitorTaskRoutine() {
        currentlyLocked := this.CheckLockScreen()

        ; 检测锁屏状态变化
        if (currentlyLocked != this.isLocked) {
            this.isLocked := currentlyLocked

            ; 触发特定事件
            if currentlyLocked
                this.OnScreenLockedCallback()
            else
                this.OnScreenUnlockedCallback()
        }
    }

    CheckLockScreen() {
        if h := DllCall("User32\OpenInputDesktop", "int", 0, "int", 0, "int", 1, "ptr") {
            DllCall("User32\CloseDesktop", "ptr", h)
            return false
        }
        return true
    }
}
