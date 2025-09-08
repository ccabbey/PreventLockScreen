#Requires AutoHotkey v2.0

/** @description
 * 输出到控制台
 * @param {String} caller 调用函数名
 * @param {String} message Debug消息
 */
DebugLog(caller, message) {
    OutputDebug A_ScriptName ' => ' StrReplace(caller, '.Prototype', '') ' => ' message
}
