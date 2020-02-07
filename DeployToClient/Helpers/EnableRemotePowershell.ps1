Enable-PSRemoting -Force

# Set start mode to automatic
Set-Service WinRM -StartMode Automatic

# Verify start mode and state - it should be running
Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}

# Trust all hosts
Set-Item WSMan:localhost\client\trustedhosts -value * -Force
# $curValue = (get-item wsman:\localhost\Client\TrustedHosts).value
# set-item wsman:\localhost\Client\TrustedHosts -value "$curValue, RDE20007.umhs.med.umich.edu" -Force
# $curValue = (get-item wsman:\localhost\Client\TrustedHosts).value
# set-item wsman:\localhost\Client\TrustedHosts -value "$curValue, WATSON-BB-OVERSEER.local" -Force

#set-item wsman:\localhost\Client\TrustedHosts -value "RDE20007.umhs.med.umich.edu, WATSON-BB-OVERSEER.local" -Force
#set-item wsman:\localhost\Client\TrustedHosts -value "10.17.158.33, 10.17.158.49" -Force

# Verify trusted hosts configuration
# Get-Item –Path WSMan:\localhost\Client\TrustedHosts