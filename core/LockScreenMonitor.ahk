#Requires AutoHotkey v2.0
#Include ..\utils\Task.ahk

class LockScreenMonitor {
    /** 父级注册的锁屏事件回调方法 */
    OnScreenLockedCallback := unset

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

    /** 监视任务流程 */
    MonitorTaskRoutine() {
        currentlyLocked := this.CheckLockScreen()

        ; 检测锁屏状态变化
        if (currentlyLocked != this.isLocked) {
            this.isLocked := currentlyLocked
            ; 触发回调方法
            if currentlyLocked
                this.OnScreenLockedCallback()
        }
    }

    /** 检查实时的锁屏状态 */
    CheckLockScreen() {
        if h := DllCall("User32\OpenInputDesktop", "int", 0, "int", 0, "int", 1, "ptr") {
            DllCall("User32\CloseDesktop", "ptr", h)
            return false
        }
        return true
    }
}
