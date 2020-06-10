@echo off
REM Enable powershell scripts from network shares.
powershell.exe -command "Set-ExecutionPolicy Bypass -Force"
powershell.exe -command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force"

REM Map the network drives
call "Helpers\MapNetworkDrives.cmd"
cd "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient"
S:

REM For Deploy:
REM call "MainDeployScript.cmd"
REM For Run:
call "MainRunScript.cmd"

REM Disable powershell scripts from network shares again
REM powershell.exe -command "Set-ExecutionPolicy Restricted -Force"

