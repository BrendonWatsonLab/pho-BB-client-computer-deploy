$connectInfo = Get-NetConnectionProfile
Set-NetConnectionProfile -Name $connectInfo.Name -NetworkCategory Private