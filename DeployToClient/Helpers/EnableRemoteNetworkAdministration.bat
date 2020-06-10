@echo off
echo Enabling Remote Network Admin...
powershell.exe -command "Set-ExecutionPolicy Bypass -Force"
powershell.exe -command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force"
call "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\Registry\installRegistryFiles.bat"
call "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\AllowNetworkServicesThroughFirewall.bat"
powershell.exe -command "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\EnableRemotePowershell.ps1"

echo "done."
pause
