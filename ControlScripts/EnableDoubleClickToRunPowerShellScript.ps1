# Enables Double-clicking powershell scripts in Explorer to run them.
# Copied from https://stackoverflow.com/questions/10137146/is-there-a-way-to-make-a-powershell-script-work-by-double-clicking-a-ps1-file
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
Set-ItemProperty -Path "HKCR:\Microsoft.PowerShellScript.1\Shell\open\command" -name '(Default)' -Value '"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -noLogo -ExecutionPolicy unrestricted -file "%1"'