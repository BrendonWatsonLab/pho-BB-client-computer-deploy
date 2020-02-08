REM This is called to deploy the templates to the clients from the server. It need not be done every time, and shouldn't, as any user-changed parameters would be overwritten
call "Helpers\CopyTemplateFilesFromServer.cmd"
powershell.exe -command ".\Helpers\SpecifyTemplateFilesAndDeploy.ps1"