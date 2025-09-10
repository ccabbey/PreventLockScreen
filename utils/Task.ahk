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

    Start() {
        SetTimer(this.task, this.period)
        this.running := true
    }

    Stop() {
        SetTimer(this.task, 0)
        this.running := false
    }
    Restart() {
        this.Stop()
        this.Start()
    }
    ChangePeriod(newPeriod) {
        this.period := newPeriod
        this.Stop()
        this.Start()

    }
}
