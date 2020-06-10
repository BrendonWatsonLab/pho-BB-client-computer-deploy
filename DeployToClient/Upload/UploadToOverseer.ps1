# function Get-Current-Computer-Name-Object()
# {
#   $TargetComp="localhost"
#   $computerNameObj = GWMI Win32_ComputerSystem -computername $TargetComp -Authentication 6
#   return $computerNameObj
# }

# function Get-Current-Hostname()
# {
#   # Get the current computer name
#   $computerNameObj = Get-Current-Computer-Name-Object
#   $computerName = $computerNameObj.Name
#   return $computerName
# }

function Get-Computer-Hostname()
{
    return $env:computername    
}
function Get-Current-BehavioralBoxID-From-Hostname()
{
    $currentHostname = Get-Computer-Hostname
    Write-host "Current Computer Name is " $currentHostname
    $currentHostnameArray = $currentHostname.Split("-")
    $currentBBID = $currentHostnameArray[2]
    Write-host "Parsed Behavioral Box ID: " $currentBBID
    return $currentBBID
}

function Get-Overseer-EventData-Path-String()
{
    $currentBBID = Get-Current-BehavioralBoxID-From-Hostname
    $currentString = "I:\EventData\BB$($currentBBID)"
    return $currentString
}

function Get-Overseer-Video-Path-String()
{
    $currentBBID = Get-Current-BehavioralBoxID-From-Hostname
    $currentString = "I:\Videos\BB$($currentBBID)"
    return $currentString
}

function Get-Local-Video-Path-String()
{
    $currentBBID = Get-Current-BehavioralBoxID-From-Hostname
    $currentString = "E:\$($currentBBID)"
    return $currentString
}

function Upload-EventData()
{
  $localDataOutputPath = "C:\Common\data"
  $serverDataOutputPath = Get-Overseer-EventData-Path-String
  ROBOCOPY $localDataOutputPath $serverDataOutputPath /e 
}

function Upload-Videos()
{
  $localVideoPath = Get-Local-Video-Path-String
  $serverVideoOutputPath = Get-Overseer-Video-Path-String
  ROBOCOPY $localVideoPath $serverVideoOutputPath /e
}

function Upload-All()
{
	Upload-EventData
	Upload-Videos
}

$currentBBID = Get-Current-BehavioralBoxID-From-Hostname

# Upload to the server
Upload-All


