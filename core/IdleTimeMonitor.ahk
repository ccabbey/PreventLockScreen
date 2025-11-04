#Requires AutoHotkey v2.0
#Include ..\utils\Task.ahk
#Include ..\utils\Debug.ahk

;通过鼠标坐标变化来判断电脑是否处在Idle状态
class IdleTimeMonitor {
    /** 父级注册的锁屏事件回调方法 */
    OnMaxIdleTimeReachedCallback := unset

    ConfigFile := A_AppData '\PLSHpr.ini'

    __new() {

        ;检查配置文件
        if !FileExist(this.ConfigFile) {
            content := "[IdleTimeMonitor]`n"
            content .= 'MaxIdleTime = 120'
            FileAppend(content, this.ConfigFile)
        }
        this.monitorTask := Task(ObjBindMethod(this, 'MonitorTaskRoutine'), 60000)
        this.running := false
        ; 最大闲置运行时间限制，单位min
        this.MaxIdleTime := IniRead(this.ConfigFile, 'IdleTimeMonitor', 'MaxIdleTime')
        ; 当前闲置时间，单位min
        this.CurrentIdleTime := 0
        ; 当前服务启动时间戳，单位ms（windows内置计时器）
        this.CachedTimeStamp := 0

        this.LastMousePosX := unset
        this.LastMousePosY := unset
    }

    Start() {
        ; 启动服务时先初始化成员变量
        MouseGetPos(&X, &Y)
        this.LastMousePosX := X
        this.LastMousePosY := Y
        this.CachedTimeStamp := A_TickCount
        this.CurrentIdleTime := 0

        this.monitorTask.Start()
        this.running := true
        DebugLog A_ThisFunc, "开始运行闲置检测服务"
        DebugLog A_ThisFunc, "StartingTimeStamp: " this.CachedTimeStamp
    }

    Stop() {
        if this.running {
            this.monitorTask.Stop()
            this.running := false
            DebugLog A_ThisFunc, "停止运行闲置检测服务"
        }

    }

    /** 监视任务流程 */
    MonitorTaskRoutine() {
        DebugLog A_ThisFunc, "检查当前闲置状态..."
        ;先获取当前鼠标坐标
        X := Y := 0
        MouseGetPos(&X, &Y)
        DebugLog A_ThisFunc, "原始坐标: " this.LastMousePosX ", " this.LastMousePosY
        DebugLog A_ThisFunc, "当前坐标: " X ", " Y
        DebugLog A_ThisFunc, "当前闲置时间：" this.CurrentIdleTime " mins"

        ; 更新闲置时间
        this.CurrentIdleTime := Round((A_TickCount - this.CachedTimeStamp) / 1000 / 60, 1)

        ;如果鼠标坐标变更，则闲置时间清零
        if (this.LastMousePosX != X and this.LastMousePosY != Y) {
            this.LastMousePosX := X
            this.LastMousePosY := Y
            this.CachedTimeStamp := A_TickCount
            DebugLog A_ThisFunc, "检测到鼠标坐标更新，重置闲置时间"
        }

        ;检查是否到达最大闲置时间
        if this.CurrentIdleTime > this.MaxIdleTime {
            this.OnMaxIdleTimeReachedCallback()
        }
    }

}
