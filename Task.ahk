#Requires AutoHotkey v2.0

class Task {
    __new(callback, period?) {
        this.task := ObjBindMethod(this, callback)
        this.period := period
        this.count := 0

    }

    Start() {
        ;SetTimer(this.task, this.period)
        sleep 0
    }
    Pause() {

    }
    Stop() {

    }
    Reset() {

    }
}

class SingleTask extends Task {
    __new(callback, delay := 0) {
        super.__new(callback, delay)
    }
}

;1. Task类用于管理周期性任务
;2.
