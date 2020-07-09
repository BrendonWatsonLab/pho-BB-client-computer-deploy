## PSFramework Setup:
# From https://adamtheautomator.com/powershell-logging/
# https://psframework.org/documentation/quickstart/psframework.html

From an admin Powershell Prompt:
    Install-Module PSFramework
    Y
    A

Set-PSFLoggingProvider -Name 'logfile' -Enabled $true



PS51> Set-PSFLoggingProvider -Name logfile -Enabled $true -FilePath 'C:\Common\info\UploadScript.log'
