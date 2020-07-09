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


## Testing Method:
Ultimately tested using a CMD.exe shell (non Admin) logged in as the user the Task Scheduler runs as.
    C:\Users\WatsonLab>c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Executionpolicy Bypass -file "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1

I installed the PSFramework logging Powershell module using "Install-Module PSFramework" from an admin Powershell prompt, and added "Set-PSFLoggingProvider -Name logfile -Enabled $true -FilePath 'C:\Common\info\UploadScript.log'" to the top of the script in question.
After much tweaking, this finally allowed me to finally receive the log below which I identified as the core problem.

## Core Problem:
"Upload-Videos","Warning","107","Error performing ROBOCOPY Upload-Videos(). | Exception calling ""GetUnresolvedProviderPathFromPSPath"" with ""1"" argument(s): ""Cannot find drive. A drive with the name 'I' does not exist.""","<Unknown>","5c243c94-b14e-4041-872e-079a88523e3d","Failure",,"7/9/2020 1:57:13 AM","Debug, Warning","WATSON-BB-16\WatsonLab"


# Complications:
## Task Scheduler Refresh Issue:
This is trivial in retrospect, but Task Scheduler does not automatically refresh to update the task execution status. As a result, right clicking the task and going to "Run" results in the status updating (changing to "Running...") but never changing after that, making it appear as if the task were stuck executing or failing to complete. It was only after I observed that the script successfully finished in my log file and messing around with various exit status codes that I realized one must manually refresh the Task Scheduler (for example using F5) to see the updated execution status.

## Session 0 Isolation Mode:
https://stackoverflow.com/questions/45110750/powershell-task-scheduler-stuck-running
When you run your task with "Run whether user logged in or not", it runs in something called "Session 0 isolation mode", which has restrictions on displaying graphical interfaces.


UploadToOverseerFinal

# Final Combined Command Executed:
c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1"