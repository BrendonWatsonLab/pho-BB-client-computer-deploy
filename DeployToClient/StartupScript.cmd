@echo off
powershell.exe -command "Set-ExecutionPolicy Bypass -Force"
call "Helpers\MapNetworkDrives.cmd"
cd "S:\BB-Computer-Deploy-01-21-2020\DeployToClient"
S:
powershell.exe -command ".\Helpers\EnableRemotePowershell.ps1"
call "MainRunScript.cmd"
powershell.exe -command "Set-ExecutionPolicy Restricted -Force"

