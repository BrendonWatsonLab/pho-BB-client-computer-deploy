function Get-Current-Computer-Name-Object()
{
  $TargetComp="localhost"
  $computerNameObj = GWMI Win32_ComputerSystem -computername $TargetComp -Authentication 6
  return $computerNameObj
}

function Get-Current-Hostname()
{
  # Get the current computer name
  $computerNameObj = Get-Current-Computer-Name-Object
  $computerName = $computerNameObj.Name
  return $computerName
}

function Get-Current-BehavioralBoxID-From-Hostname()
{
    $currentHostname = Get-Current-Hostname
    Write-host "Current Computer Name is " $currentHostname
    $currentHostnameArray = $currentHostname.Split("-")
    $currentBBID = $currentHostnameArray[2]
    Write-host "Parsed Behavioral Box ID: " $currentBBID
    return $currentBBID
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

function Upload-Videos()
{
  $localVideoPath = Get-Local-Video-Path-String
  $serverVideoOutputPath = Get-Overseer-Video-Path-String
  ROBOCOPY $localVideoPath $serverVideoOutputPath /e
}

  # Upload to the server
  Upload-Videos


