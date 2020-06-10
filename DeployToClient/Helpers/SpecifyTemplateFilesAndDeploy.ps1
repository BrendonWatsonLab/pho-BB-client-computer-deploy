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

function Get-OBS-Filename-Formatting-String()
{
    $currentBBID = Get-Current-BehavioralBoxID-From-Hostname
    # $currentString = 'BehavioralBox_B' $currentBBID '_T%FULLDATETIME'
    $currentString = "BehavioralBox_B$($currentBBID)_T%FULLDATETIME"
    return $currentString
}

$currentBBID = Get-Current-BehavioralBoxID-From-Hostname
$currentOBSString = Get-OBS-Filename-Formatting-String
# $videoOutputPath = "F:/BaslerMovies/Behavioral Boxes Extended"
# $videoOutputPath = "C:\Common\data"
$videoOutputPath = "E:\Common\data"

$template = Get-Content 'C:\Common\temp\basic.ini' -Raw
# $template = Get-Content 'C:\Users\watsonlab\AppData\Roaming\obs-studio\basic\profiles\Untitled\basic.ini' -Raw
$expanded = Invoke-Expression "@`"`r`n$template`r`n`"@"

# $expanded
# $template = Get-Content 'C:\Users\watsonlab\AppData\Roaming\obs-studio\basic\profiles\Untitled\basic.ini' -Raw
# $expanded > 'C:\Users\watsonlab\AppData\Roaming\obs-studio\basic\profiles\Untitled\basic.ini'

# Write out to local file location:
Set-Content -Path 'C:\Users\watsonlab\AppData\Roaming\obs-studio\basic\profiles\Untitled\basic.ini' -Value $expanded

