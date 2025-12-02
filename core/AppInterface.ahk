#Requires AutoHotkey v2.0

class AppInterface {

    __new(appController) {
        this.app := appController
    }

    UseTrayMenu() {
        return this.app.ITray
    }

    UseHotkey() {
        return this.app.IHotkey
    }

    UseConfig() {
        return this.app.IConfig
    }

    UseModule(moduleName) {
        if (this.app.mods.HasProp(moduleName)) {
            return this.app.mods.%moduleName%
        }
        return unset
    }

    UseService(serviceName) {
        if (this.app.mods.HasProp(serviceName)) {
            return this.app.services.%serviceName%
        }
        return unset
    }
}
