# Windows RC003 实机设置

把 **小米蓝牙遥控器 2 Pro（RC003 / RC003-MS）** 接到 Windows：按键映射 + 按麦克风键语音出字。

本仓库是 **本机真机跑通后的设置笔记与配置模板**，不是 Remote Mic 本体。软件仍从上游社区预览版安装。

**已在本机验证（2026-08-18 / 19）**

- 设备：RC003-MS，蓝牙 VID `0x2717` / PID `0x32B8`
- 系统：Windows 10，工作组
- 出字路径：遥控器 ATVV → `CABLE Input` → `CABLE Output` → **Win+H** 系统语音输入

---

## 和 Mac 的差别（先看这个）

| Mac 无线麦 / MiRemote | 这台 Windows |
| --- | --- |
| 豆包输入法 | **没有 Windows 版**。用 **Win+H**，或讯飞/搜狗 |
| `MiRemoteV 2ch` / BlackHole | **VB-CABLE**：`CABLE Input` / `CABLE Output` |
| 默认语音热键 Fn / 右 Option | 默认 `ralt+space` 在 Windows = **Alt+空格**，会弹出「还原/最小化」窗口菜单，必须改成 `win+h` |
| USB 接收器 | RC003 **只用蓝牙**。若同时插着 `Mi USB Receiver`（VID `2717` PID `5094`），会抢按键，开机还可能卡 BIOS |

不要把 2.4G USB 接收器遥控器当成 RC003。RC003 配对：同时长按 **主页 + 菜单**。

---

## 1. 安装软件

上游（未签名社区预览，仅 RC003）：

- 发布页：https://github.com/HD838A/remote-mic-app/releases/tag/windows-v0.1.0-community-preview
- 源码：https://github.com/miaomiaozii/windows-remote-mic-app
- 安装器：`RemoteMicRC003Setup-0.1.0-candidate-unsigned.exe`

下载后用同目录 `SHA256SUMS.txt` 校验。安装器 SHA256：

```
55660a5c514ef851ffb39a97b6711758ab7ff7882e1a1b455267be95a7322293
```

SmartScreen 会报未知发布者：更多信息 → 仍要运行。  
安装到当前用户，不需要管理员。默认目录：

`%LOCALAPPDATA%\RemoteMic\RC003\`

预览版含 Frida / `WUDFHost` 旁路，杀软可能拦。返回键、音量键不稳时，用**管理员**再点一次「启动」。

---

## 2. 配对 RC003

1. 拔掉 USB 接收器（如果有）
2. 遥控器同时长按 **主页 + 菜单**，进入配对
3. Windows 设置 → 蓝牙 → 添加「小米蓝牙语音遥控器」
4. 设备管理器里应出现 HID over GATT，实例含 `VID_2717` `PID_32B8`

---

## 3. 虚拟声卡（VB-CABLE）

Remote Mic **不会**自动装驱动。在设置 → **检查与修复** 里点安装 VB-CABLE（UAC + **重启电脑**）。

方向不能反：

| 谁 | 选哪个 |
| --- | --- |
| Remote Mic「语音输出设备」 | **`CABLE Input`**（不要选 `CABLE In 16ch`） |
| Windows 声音 → 输入 / Win+H 用的麦克风 | **`CABLE Output`** |

不要把系统默认**播放**设备改成 CABLE，否则桌面声音会进虚拟线。

---

## 4. 语音热键：必须改成 Win+H

豆包输入法没有 Windows 版。网页豆包的语音条只对浏览器有效。

1. Remote Mic 连接页，点语音快捷键右边的 **录**
2. 按键盘 **Win+H**，框里应是 `lwin+h` / `win+h`
3. 模式用 **切换（toggle）**：点一下开，再点一下关
4. **保存并启动桥接**

改完热键必须重启桥接，否则仍发旧的 `ralt+space`。

`config.json` 里应对：

```json
"voice_hotkey": "lwin+h",
"voice_shortcut_enabled": true,
"voice_trigger_mode": "toggle",
"output_endpoint_name": "CABLE Input (VB-Audio Virtual C",
"selected_device_profile": "xiaomi-rc003"
```

完整模板见 [`config.example.json`](config.example.json)。复制到：

`%LOCALAPPDATA%\RemoteMic\RC003\config.json`

然后重启桥接。

---

## 5. 打开 Windows 在线语音识别

Win+H 依赖「在线语音识别」。若开关是灰的、写着「由组织隐藏或管理」，本机（工作组）通常是这条策略：

`HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization\AllowInputPersonalization = 0`

管理员 PowerShell 运行 [`scripts/unlock-win-speech.ps1`](scripts/unlock-win-speech.ps1)，关掉设置页再打开，把开关拨到 **开**。

第一次 Win+H 会「正在初始化」（下语音包，需联网）。等它结束，不要连按麦克风键。

---

## 6. 日常使用

1. 开机后从开始菜单点 **启动 Remote Mic · RC003**（不会自动开机启动）
2. 光标点进要打字的窗口
3. 麦克风键 **点一下** 开始，说话；再点一下结束  
   不要长按乱按，否则会话会被掐成 `too_short` / `empty`
4. 按键默认：方向=方向键，OK=回车，返回=退格，音量=系统音量，电源=Esc，主页=显示桌面，TV=切窗口

改键：设置 → 按键映射。模板见 [`key_bindings.example.json`](key_bindings.example.json)。

日志：`%LOCALAPPDATA%\RemoteMic\RC003\logs\app.log`

健康启动应看到：

```
exactly one RC003 candidate resolved
voice capabilities received: version=0x0100 sample_rate=16000.0 frame_size=120
startup: RC003 HID report tap enabled
```

说话时应有 `result=signal`。出字失败先看 Windows 输入是不是 `CABLE Output`。

---

## 7. 踩过的坑

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| 弹出还原/最小化/关闭 | 还在发 `ralt+space`（= Alt+空格） | 热键改 `lwin+h` 并**重启桥接** |
| 弹出豆包网页语音条 | 网页端热键，不是输入法 | 不要用网页当系统听写 |
| `ATVV voice service not found` | 遥控器休眠 / 刚开机 | 按任意键唤醒，再启动桥接 |
| `no usable output endpoint` | 没选 CABLE Input | 连接页选好再保存 |
| 右 / 主页 / 音量− 没反应 | USB 接收器抢键，或没开 Frida 旁路 | 拔 USB；管理员启动 |
| 重启卡 BIOS、键盘灯不亮 | USB HID 接收器拖死枚举 | 拔掉 `Mi USB Receiver` 再开机 |
| 桥接「运行中」但没出字 | 进程在，但没点进输入框 / 语音包还在初始化 | 记事本点一下再按麦克风 |

---

## 来源

- Mac 上游：https://github.com/HD838A/remote-mic-app （GPL-3.0）
- Windows 实现：https://github.com/miaomiaozii/windows-remote-mic-app （GPL-3.0）
- 本仓库只发布设置说明和配置模板，不重新分发未签名安装包
