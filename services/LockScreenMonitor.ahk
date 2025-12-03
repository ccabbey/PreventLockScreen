#Requires AutoHotkey v2.0

class LockScreenMonitor {
    /** 父级注册的锁屏事件回调方法 */
    OnScreenLockedCallback := unset

    __new() {
        this.monitorTask := Task(ObjBindMethod(this, 'MonitorTaskRoutine'), 10000)
        this.isLocked := false
        this.running := false
    }

    Start() {
        this.monitorTask.Start()
        this.running := true
        DebugLog A_ThisFunc, "开始运行锁屏检测服务"
    }

    Stop() {
        if this.running {
            this.monitorTask.Stop()
            this.running := false
            DebugLog A_ThisFunc, "停止运行锁屏检测服务"
        }

    }

    /** 监视任务流程 */
    MonitorTaskRoutine() {
        ;DebugLog A_ThisFunc, "检查当前锁屏状态..."
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
