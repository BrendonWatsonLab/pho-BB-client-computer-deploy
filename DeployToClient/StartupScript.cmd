@echo off
powershell.exe -command "Set-ExecutionPolicy Bypass -Force"
call "Helpers\MapNetworkDrives.cmd"
cd "S:\BB-Computer-Deploy-01-21-2020\DeployToClient"
S:
REM For Deploy:
REM call "MainDeployScript.cmd"
REM For Run:
call "MainRunScript.cmd"
powershell.exe -command "Set-ExecutionPolicy Restricted -Force"

