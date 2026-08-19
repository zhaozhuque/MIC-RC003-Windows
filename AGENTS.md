# Agent instructions — Windows RC003

For Codex, Claude Code, Hermes, Cursor, OpenCode, Copilot CLI.

Repo purpose: **field-tested Windows setup notes** for Xiaomi Bluetooth Remote 2 Pro (RC003). Not the Remote Mic binary.

Read `README.md` first. Then follow this file. Do not invent a USB-dongle path.

---

## Hard hardware facts

- RC003 / RC003-MS is **Bluetooth LE only**.
- There is **no official USB receiver** for this remote.
- A charging cable does **not** expose the remote to Windows.
- The PC **must have a working Bluetooth radio** (built-in or a USB Bluetooth adapter). A desktop without Bluetooth cannot use RC003 until a Bluetooth adapter is installed.
- If PnP shows `VID_2717` `PID_5094` / `Mi USB Receiver`, that is a **different** 2.4G product. Ignore it. Unplug it. Do not write setup steps around it.
- Success identity after pairing: `VID_2717` `PID_32B8` (HID over GATT), name like 小米蓝牙语音遥控器.

If Bluetooth is off or missing, **stop and tell the user**. Do not proceed to installers.

---

## What you may do without asking

- Check Bluetooth radio, paired devices, CABLE endpoints, Remote Mic process, `config.json`, `app.log`.
- Copy `config.example.json` / `key_bindings.example.json` into `%LOCALAPPDATA%\RemoteMic\RC003\` **after** stating you will overwrite.
- Restart the Remote Mic **bridge** (`RemoteMicRC003.exe --bridge`) after config changes.

## What you must not do without the user

- Run the unsigned installer / click through SmartScreen.
- Install VB-CABLE (kernel audio driver, needs UAC + reboot).
- Change system default playback device to CABLE.
- Type GitHub / Microsoft passwords.
- Assume Doubao IME exists on Windows — it does not.

---

## Discovery commands (Windows, git-bash or PowerShell)

Bluetooth radio / adapter present:

```powershell
Get-PnpDevice -Class Bluetooth |
  Where-Object { $_.FriendlyName -match 'Adapter|Radio|RZ616|Intel|Realtek' } |
  Select-Object Status, FriendlyName
```

RC003 paired (must be PID 32B8, not 5094):

```powershell
Get-PnpDevice |
  Where-Object { $_.InstanceId -match 'PID&32B8|VID_2717' } |
  Select-Object Status, Class, FriendlyName, InstanceId
```

CABLE endpoints:

```powershell
Get-PnpDevice |
  Where-Object { $_.FriendlyName -match 'CABLE Input \(|CABLE Output \(' } |
  Select-Object Status, FriendlyName
```

Bridge process:

```powershell
Get-Process RemoteMicRC003 -ErrorAction SilentlyContinue |
  Select-Object Id, StartTime, MainWindowTitle
```

Latest voice / connect lines:

```powershell
Select-String -Path "$env:LOCALAPPDATA\RemoteMic\RC003\logs\app.log" `
  -Pattern 'startup:|capabilities|ATVV|PCM summary|fail' |
  Select-Object -Last 20
```

Healthy connect:

```
exactly one RC003 candidate resolved
voice capabilities received: version=0x0100 sample_rate=16000.0 frame_size=120
startup: RC003 HID report tap enabled
```

Healthy speech: `result=signal` (not `too_short` / `empty`).

---

## Ordered setup (human does pairing; you verify)

1. **Bluetooth on the PC.** If no radio: tell the user to enable Bluetooth or plug a USB **Bluetooth adapter**. Never ask for an RC003 USB receiver.
2. User pairs RC003: hold **Home + Menu**, add in Windows Bluetooth settings.
3. You verify `PID_32B8`. If only `PID_5094`, tell them they paired/plugged the wrong device.
4. Software: unsigned community preview  
   https://github.com/HD838A/remote-mic-app/releases/tag/windows-v0.1.0-community-preview  
   Installer SHA256: `55660a5c514ef851ffb39a97b6711758ab7ff7882e1a1b455267be95a7322293`  
   Installs to `%LOCALAPPDATA%\RemoteMic\RC003\`
5. VB-CABLE: user installs from Remote Mic → 检查与修复, then **reboots the PC**.
6. Config (this repo):
   - Remote Mic output = `CABLE Input` (not `CABLE In 16ch`)
   - Windows recording / Win+H mic = `CABLE Output`
   - `voice_hotkey` = `lwin+h` (never leave `ralt+space`)
   - `voice_trigger_mode` = `toggle`
   - `selected_device_profile` = `xiaomi-rc003`
7. If Settings → Privacy → Speech toggle is grey: run `scripts/unlock-win-speech.ps1` elevated, reopen Settings, turn **Online speech recognition** on.
8. Restart bridge after any `config.json` change. Config on disk is not enough.
9. User: focus a text field (Notepad, Codex, Cursor, terminal), tap mic **once**, wait for Win+H, speak, tap again.

`ralt+space` on Windows is Alt+Space → window menu (Restore / Minimize). That is a bug, not a feature.

---

## Using with coding agents (Codex / Claude / Cursor)

Voice does **not** talk to the agent over a special API. It types into the focused window via Win+H.

1. Start Remote Mic bridge.
2. Click the agent input box so it has caret.
3. Tap RC003 mic → speak → tap again.
4. Keep Windows input device on `CABLE Output`.

Do not bind the mic key to the agent’s own hotkey unless the user asks. Default validated path is Win+H.

---

## Start / stop bridge

```powershell
# start (no window)
Start-Process "$env:LOCALAPPDATA\RemoteMic\RC003\RemoteMicRC003.exe" -ArgumentList '--bridge'

# settings UI
Start-Process "$env:LOCALAPPDATA\RemoteMic\RC003\RemoteMicRC003.exe"

# stop
Get-Process RemoteMicRC003 -ErrorAction SilentlyContinue | Stop-Process -Force
```

Bridge does not auto-start at logon unless the user asks you to add a Startup shortcut.

---

## When stuck

| Symptom | Check |
| --- | --- |
| No device found | Bluetooth off / no radio / remote asleep — press any key |
| `ATVV voice service not found` | Not connected on BLE; wait and retry; confirm PID 32B8 |
| `no usable output endpoint` | `output_endpoint_name` empty — set CABLE Input |
| Restore/Minimize menu | Still injecting `ralt+space` — set `lwin+h`, restart bridge |
| Keys missing | Unplug any `Mi USB Receiver`; start bridge as Administrator |
| Win+H initializing forever | Online speech still off, or no network |
