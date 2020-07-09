Set-PSFLoggingProvider -Name logfile -Enabled $true -FilePath 'C:\Common\info\UploadScript.log'

# Include the Invoke-Robocopy script.
. "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\Invoke-Robocopy.ps1"

# function Perform-ROBOCOPY()
# {

# 	if ($lastexitcode -eq 0)
# 	{
# 		 write-host "Robocopy succeeded"
# 	}
#    else
#    {
# 		 write-host "Robocopy failed with exit code:" $lastexitcode
#    }

# }

function Get-Computer-Hostname()
{
	return $env:computername    
}
function Get-Current-BehavioralBoxID-From-Hostname()
{
	$currentHostname = Get-Computer-Hostname
	# Write-host "Current Computer Name is " $currentHostname
	Write-PSFMessage -Level Debug -Message ("Current Computer Name is " + $currentHostname)
	$currentHostnameArray = $currentHostname.Split("-")
	$currentBBID = $currentHostnameArray[2]
	# Write-host "Parsed Behavioral Box ID: " $currentBBID
	Write-PSFMessage -Level Debug -Message ("Parsed Behavioral Box ID: " + $currentBBID)
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
	try {
		# $serverDataOutputPath | Invoke-Robocopy -Path $localDataOutputPath -ArgumentList @('/e') -PassThru
		$RobocopyResult = Invoke-Robocopy -Path $localDataOutputPath -Destination @($serverDataOutputPath) -ArgumentList @('/e') -PassThru -EnableExit
		# Write-Host $RobocopyResult
		$OutputMessage = 'Exit code: ' + $RobocopyResult.ExitCode
		# $RobocopyResult.StdOut | Write-Debug
		$OutputStandardMessage = ($RobocopyResult.StdOut -join [System.Environment]::NewLine)
		$OutputErrorMessage = ($RobocopyResult.StdErr -join [System.Environment]::NewLine)
		# Write-Host $OutputStandardMessage
		# Write-Host $OutputErrorMessage
		# ROBOCOPY $localDataOutputPath $serverDataOutputPath /e 
		Write-PSFMessage -Level Important -Message $OutputMessage -Tag 'Success'
		Write-PSFMessage -Level Debug -Message $OutputStandardMessage -Tag 'Output_STDOUT'
		Write-PSFMessage -Level Debug -Message $OutputErrorMessage -Tag 'Output_STDERR'
		
		
		Write-PSFMessage -Level Important -Message 'Successfully performed ROBOCOPY Upload-EventData().' -Tag 'Success'
	}
	catch {
		Write-PSFMessage -Level Warning -Message 'Error performing ROBOCOPY Upload-EventData().' -Tag 'Failure' -ErrorRecord $_
	}
}

function Upload-Videos()
{
  	$localVideoPath = Get-Local-Video-Path-String
  	$serverVideoOutputPath = Get-Overseer-Video-Path-String
	try {
		# $serverVideoOutputPath | Invoke-Robocopy -Path $localVideoPath -ArgumentList @('/e') -PassThru
		$RobocopyResult = Invoke-Robocopy -Path $localVideoPath -Destination @($serverVideoOutputPath) -ArgumentList @('/e') -PassThru -EnableExit
		# Write-Host $RobocopyResult
		$OutputMessage = 'Exit code: ' + $RobocopyResult.ExitCode
		# $OutputMessage = @($RobocopyResult.ExitCode) + $RobocopyResult.StdOut
		# Write-Host $OutputStandardMessage
		# Write-Host $OutputErrorMessage
		# $OutputMessage -join [System.Environment]::NewLine | Write-Error
		$OutputStandardMessage = ($RobocopyResult.StdOut -join [System.Environment]::NewLine)
		$OutputErrorMessage = ($RobocopyResult.StdErr -join [System.Environment]::NewLine)
		# $RobocopyResult.StdOut | Write-Debug			
		# ROBOCOPY $localVideoPath $serverVideoOutputPath /e
		Write-PSFMessage -Level Important -Message $OutputMessage -Tag 'Success'
		Write-PSFMessage -Level Debug -Message $OutputStandardMessage -Tag 'Output_STDOUT'
		Write-PSFMessage -Level Debug -Message $OutputErrorMessage -Tag 'Output_STDERR'
		Write-PSFMessage -Level Important -Message 'Successfully performed ROBOCOPY Upload-Videos().' -Tag 'Success'
	}
	catch {
		Write-PSFMessage -Level Warning -Message 'Error performing ROBOCOPY Upload-Videos().' -Tag 'Failure' -ErrorRecord $_
	}
}

function Upload-All()
{
	try {
		Upload-EventData
		Upload-Videos
		Write-PSFMessage -Level Important -Message 'Successfully performed all steps of Upload-All().' -Tag 'Success'
	}
	catch {
		Write-PSFMessage -Level Warning -Message 'Error performing a step of Upload-All().' -Tag 'Failure' -ErrorRecord $_
	}
}

Write-PSFMessage -Level Debug -Message '=========== Starting UploadToOverseer.ps1 Powershell script.' -Tag 'Begin'
# Write-PSFMessage -Level Debug -Message $PSVersionTable.PSVersion

# try {
# 	$currentBBID = Get-Current-BehavioralBoxID-From-Hostname
# 	Write-PSFMessage -Level Important -Message ('Successfully got current BBID: ' + $currentBBID + '.') -Tag 'Success'
# }
# catch {
# 	Write-PSFMessage -Level Warning -Message 'Error getting current BBID using Get-Current-BehavioralBoxID-From-Hostname.' -Tag 'Failure' -ErrorRecord $_
# 	# could also write $_.ScriptStackTrace
# }

# Upload to the server
Upload-All

Write-PSFMessage -Level Debug -Message '_________ Finished with UploadToOverseer.ps1 Powershell script.' -Tag 'End'

return 0