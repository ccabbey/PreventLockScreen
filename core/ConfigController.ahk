#Requires AutoHotkey v2.0

class ConfigController {

    __new() {
        this.DirPath := A_AppData '\PLSHpr\'
        this.ConfigFile := this.DirPath 'PLSHpr.ini'
        ;检查配置文件是否存在
        if !DirExist(this.DirPath)
            DirCreate(this.DirPath)
        if !FileExist(this.ConfigFile) {
            content := "[IdleTimeMonitor]`n"
            content .= 'MaxIdleTime = 120'
            FileAppend(content, this.ConfigFile)
        }
    }
    /**@param module
     * @param key
     */
    GetConfigValue(module, key) {
        return IniRead(this.ConfigFile, module, key)
    }

}
