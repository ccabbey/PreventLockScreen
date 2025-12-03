#Requires AutoHotkey v2.0

Log(message) {
    caller := GetCallerName()
    OutputDebug A_ScriptName ' => ' caller ' => ' message
}

GetCallerName() {
    try {
        throw
    } catch as e {
        ; 在调用栈中查找合适的调用者
        stack := e.Stack
        lines := StrSplit(stack, "`n", "`r")
        if (lines.Length >= 3) {
            line := lines[lines.Length - 3]
            caller := RegExMatch(line, '\[([^\]]+)\]', &match)
            return match[1]
        }
        return "Unknown"
    }
}
