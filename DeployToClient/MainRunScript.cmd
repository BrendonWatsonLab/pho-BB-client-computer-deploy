call "Helpers\EnableRemoteNetworkAdministration.bat"
call "Helpers\CopyTemplateFilesFromServer.cmd"
powershell.exe -command ".\Helpers\SpecifyTemplateFilesAndDeploy.ps1"
call "Helpers\RunStartupSoftware.cmd"