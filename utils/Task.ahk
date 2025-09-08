#Requires AutoHotkey v2.0
/** @class
 * Task类对SetTimer进行了封装，可以延后运行。  
 * 还提供了一些辅助功能。
 */
class Task {
    __new(callback, period) {
        this.task := callback
        this.period := period
        this.running := false
    }

    /** 启动任务 */
    Start() {
        SetTimer(this.task, this.period)
        this.running := true
    }

    /** 停止任务 */
    Stop() {
        SetTimer(this.task, 0)
        this.running := false
    }

    /** 重新启动任务 */
    Restart() {
        this.Stop()
        this.Start()
    }

    /** 修改任务的触发周期 */
    ChangePeriod(newPeriod) {
        this.period := newPeriod
        this.Stop()
        this.Start()

    }
}
