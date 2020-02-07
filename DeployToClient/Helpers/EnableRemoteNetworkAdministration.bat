@echo off
echo Enabling Remote Network Admin...
powershell.exe -command "Set-ExecutionPolicy Bypass -Force"
call "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Helpers\Registry\installRegistryFiles.bat"
call "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Helpers\AllowNetworkServicesThroughFirewall.bat"
powershell.exe -command "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Helpers\EnableRemotePowershell.ps1"

echo "done."
pause
