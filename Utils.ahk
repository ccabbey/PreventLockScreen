#Requires AutoHotkey v2.0

; 抖动鼠标
MoveCursor() {
    MouseMove 1, 0, 1, 'R'  ;Move the mouse one pixel to the right
    MouseMove -1, 0, 1, 'R' ;Move the mouse back one pixel
    DebugLog A_ThisFunc, '执行鼠标抖动操作...'
}

/** @description
 * 输出到控制台
 * @param {String} caller 调用函数名
 * @param {String} message Debug消息
 */
DebugLog(caller, message) {
    OutputDebug A_ScriptName ' => ' StrReplace(caller, '.Prototype', '') ' => ' message
}
