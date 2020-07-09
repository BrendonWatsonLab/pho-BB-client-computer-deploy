## PSFramework Setup:
# From https://adamtheautomator.com/powershell-logging/
# https://psframework.org/documentation/quickstart/psframework.html

From an admin Powershell Prompt:
    Install-Module PSFramework
    Y
    A

Set-PSFLoggingProvider -Name 'logfile' -Enabled $true



Set-PSFLoggingProvider -Name logfile -Enabled $true -FilePath 'C:\Common\info\UploadScript.log'


c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Executionpolicy Bypass -file "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadVideosToOverseer.ps1"

c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Executionpolicy Bypass -file "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1"
 -NoLogo -NonInteractive

-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1"


powershell.exe -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1


## Final Problem:
"Upload-Videos","Warning","107","Error performing ROBOCOPY Upload-Videos(). | Exception calling ""GetUnresolvedProviderPathFromPSPath"" with ""1"" argument(s): ""Cannot find drive. A drive with the name 'I' does not exist.""","<Unknown>","5c243c94-b14e-4041-872e-079a88523e3d","Failure",,"7/9/2020 1:57:13 AM","Debug, Warning","WATSON-BB-16\WatsonLab"

New-PSDrive -Name K -PSProvider FileSystem -Root "\\ServerName\ShareName" -Persist -Credential $cre -Scope Global

## Session 0 Isolation Mode:
https://stackoverflow.com/questions/45110750/powershell-task-scheduler-stuck-running
Welcome to Session 0 isolation mode.

When you run your task with "Run whether user logged in or not", it runs in so called session 0. You can check this with your task manager.

enter image description here enter image description here

Tasks running is Session 0 has restrictions on showing the user interface

