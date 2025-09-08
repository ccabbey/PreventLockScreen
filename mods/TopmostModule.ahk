#Requires AutoHotkey v2.0
#Include ..\utils\Debug.ahk

class TopmostModule {
    OnSetTopmostCallback := unset
    OnCancelTopmostCallback := unset

    __new() {
        this.activeWinTitle := ''
        this.excludes := 'Program Manager'
    }

    SetTopmost(winTitle := 'A') {
        if this.activeWinTitle != '' {
            this.CancelTopMost
        }
        ;通过 WinGetExStyle 获取窗口的扩展样式，然后判断是否包含 WS_EX_TOPMOST（值为 0x00000008），来判断窗口是否为“置顶”状态
        winTitle := WinGetTitle(winTitle)
        if InStr(this.excludes, winTitle) > 0
            return
        exStyle := WinGetExStyle(winTitle)
        WinSetAlwaysOnTop(1, winTitle)
        this.activeWinTitle := winTitle
        this.OnSetTopmostCallback(winTitle)
    }

    CancelTopMost(*) {
        if this.activeWinTitle != '' {
            winTitle := this.activeWinTitle
            try {
                exStyle := WinGetExStyle(winTitle)
                if (exStyle & 0x8 != 0) {    ; 0x8 即 WS_EX_TOPMOST
                    WinSetAlwaysOnTop(0, winTitle)
                }
            }
            catch {
                ;如果无法获取到此窗口的Title，则程序可能已经被关闭了
            }
            this.activeWinTitle := ''
            this.OnCancelTopmostCallback(winTitle)
        }
    }
}
