# Prevent LockScreen Helper (PLSHpr)

[![AutoHotkey](https://img.shields.io/badge/Language-AutoHotkey-green.svg)](https://www.autohotkey.com/)
![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)

## 简介

PLSHpr (Prevent LockScreen Helper) 是一个防止 Windows 系统在空闲一段时间后自动进入屏保和锁屏的小工具。它通过定时模拟鼠标移动来重置系统待机时间累计，从而防止系统自动锁屏。

此外，该工具还提供黑屏遮罩功能来模拟屏幕关闭效果，以及窗口置顶功能。

## 功能特性

### 1. 防止自动锁屏
- 定时模拟鼠标微小移动来重置系统空闲时间
- 可通过托盘菜单或快捷键快速启用/禁用

### 2. 黑屏遮罩
- 在所有显示器上创建黑色遮罩来模拟屏幕关闭效果
- 有助于节省电力和延长显示器寿命
- 快捷键: `Shift + ESC` 切换开关

### 3. 窗口置顶
- 将当前活动窗口设置为始终置顶
- 同一时间只能有一个窗口置顶
- 置顶新窗口会自动取消之前窗口的置顶状态
- 快捷键:
  - `Ctrl + Shift + Alt + A` - 置顶当前窗口
  - `Ctrl + Shift + Alt + Z` - 取消窗口置顶
- 也可以通过点击托盘菜单的置顶窗口标题来取消置顶

### 4. 智能锁屏检测
- 自动检测系统锁屏状态
- 当用户主动锁屏时，自动禁用防锁屏功能

## 使用方法

1. 运行 PLSHpr.ahk 脚本
2. 程序将在系统托盘中运行
3. 右键点击托盘图标查看菜单选项:
   - 防止自动锁屏 - 启用/禁用防锁屏功能
   - 黑屏 Shift+ESC - 启用/禁用黑屏遮罩
   - 当前置顶窗口 - 管理置顶窗口
   - 停用热键 - 临时停用所有热键
   - 退出 - 完全退出程序


## 快捷键列表

| 快捷键                 | 功能         |
| ---------------------- | ------------ |
| Shift + ESC            | 切换黑屏遮罩 |
| Ctrl + Shift + Alt + A | 置顶当前窗口 |
| Ctrl + Shift + Alt + Z | 取消窗口置顶 |

## 模块说明

- `PreventLockModule` - 防锁屏模块，通过定时移动鼠标防止系统锁屏
- `BlackoutModule` - 黑屏遮罩模块，在所有显示器上创建黑色遮罩
- `TopmostModule` - 窗口置顶模块，管理窗口置顶功能
- `LockScreenMonitor` - 锁屏监视器，检测系统锁屏状态

## 许可证

本项目采用 [MIT License](LICENSE) 开源协议。