# Unlock Windows online speech / Win+H on a workgroup PC.
# The Settings toggle is grey when this local policy is 0
# (the UI still says "managed by your organization").
# Run in an elevated PowerShell, then close and reopen Settings.

$ErrorActionPreference = 'Stop'

$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
if (-not (Test-Path $policy)) { New-Item -Path $policy -Force | Out-Null }
Set-ItemProperty -Path $policy -Name 'AllowInputPersonalization' -Value 1 -Type DWord

$cuPolicy = 'HKCU:\SOFTWARE\Policies\Microsoft\InputPersonalization'
if (-not (Test-Path $cuPolicy)) { New-Item -Path $cuPolicy -Force | Out-Null }
Set-ItemProperty -Path $cuPolicy -Name 'RestrictImplicitInkCollection' -Value 0 -Type DWord
Set-ItemProperty -Path $cuPolicy -Name 'RestrictImplicitTextCollection' -Value 0 -Type DWord

$privacy = 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'
if (-not (Test-Path $privacy)) { New-Item -Path $privacy -Force | Out-Null }
Set-ItemProperty -Path $privacy -Name 'HasAccepted' -Value 1 -Type DWord

Write-Host 'AllowInputPersonalization=1, OnlineSpeechPrivacy.HasAccepted=1'
Write-Host 'Close Settings and reopen: Settings -> Privacy -> Speech. Turn Online speech recognition ON.'
