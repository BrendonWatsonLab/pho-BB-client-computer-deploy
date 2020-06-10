@echo off 
Rem Uploads the video and data files to Google Drive for backup purposes
REM Enable powershell scripts from network shares.
REM powershell.exe -command "Set-ExecutionPolicy Bypass -Force"
powershell.exe -command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force"

REM Maps required Network Drives:
S:
call "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\MapNetworkDrives.cmd"
REM net use I: \\WATSON-BB-OVERSEER\ServerInternal-00 cajal1852 /user:WATSON-BB-OVERSEER\watsonlab /persistent:yes
REM net use O: \\WATSON-BB-OVERSEER\ServerInternal-01 cajal1852 /user:WATSON-BB-OVERSEER\watsonlab /persistent:yes
REM Run the upload script:
powershell.exe -command "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1"
