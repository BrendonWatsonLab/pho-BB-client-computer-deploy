Set-PSFLoggingProvider -Name logfile -Enabled $true -FilePath 'C:\Common\info\UploadScript.log'

# Include the Invoke-Robocopy script.
. "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\Invoke-Robocopy.ps1"

# Include the Start-ConsoleProcess script.
. "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\Start-ConsoleProcess.ps1"

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

function Invoke-Mount-Overseer-Network-Drive()
{
	# Invoke Net use:
	# $Result = Start-ConsoleProcess -FilePath 'robocopy.exe' -ArgumentList $AllArguments
	# net use I: \\WATSON-BB-OVERSEER\ServerInternal-00 cajal1852 /user:WATSON-BB-OVERSEER\watsonlab /persistent:yes
	# 'aaa', 'bbb', 'ccc' | Start-ConsoleProcess -FilePath find -ArgumentList '"aaa"'
	$AllArguments = @('use', 'I:', '\\WATSON-BB-OVERSEER\ServerInternal-00', 'cajal1852', '/user:WATSON-BB-OVERSEER\watsonlab', '/persistent:yes')
	# $AllArguments = @('use', 'I:', '\\WATSON-BB-OVERSEER\ServerInternal-00', 'cajal1852', '/user:WATSON-BB-OVERSEER\watsonlab', '/persistent:yes')
	# $AllArguments = @('use', 'I:', '\\\\WATSON-BB-OVERSEER\\ServerInternal-00', 'cajal1852', '/user:WATSON-BB-OVERSEER\\watsonlab', '/persistent:yes')
	$Result = Start-ConsoleProcess -FilePath net -ArgumentList $AllArguments
	# return $Result
}

function Get-Computer-Hostname()
{
	return $env:computername    
}
function Get-Current-BehavioralBoxID-From-Hostname()
{
	$currentHostname = Get-Computer-Hostname
	# Write-host "Current Computer Name is " $currentHostname
	# Write-PSFMessage -Level Debug -Message ("Current Computer Name is " + $currentHostname)
	$currentHostnameArray = $currentHostname.Split("-")
	$currentBBID = $currentHostnameArray[2]
	# Write-host "Parsed Behavioral Box ID: " $currentBBID
	# Write-PSFMessage -Level Debug -Message ("Parsed Behavioral Box ID: " + $currentBBID)
	return $currentBBID
}

function Get-Overseer-EventData-Path-String()
{
	$currentBBID = Get-Current-BehavioralBoxID-From-Hostname
	$currentString = "I:\EventData\BB$($currentBBID)"
	if (! (Test-Path $currentString -IsValid)) {
		# Try to remount the network drive (I://) if needed.
		Write-PSFMessage -Level Debug -Message ("Remote path " + $currentString + " doesn't exist. Attempting to re-mount network drive I...")
		Invoke-Mount-Overseer-Network-Drive
		 
		if (! (Test-Path $currentString -IsValid)) {
			Write-PSFMessage -Level Debug -Message "Get-Overseer-EventData-Path-String(): path doesn't exist and didn't appear upon re-mounting the network drives!"
			$Remote_EventPathMissing_Error = New-Object System.IO.DirectoryNotFoundException "Get-Overseer-EventData-Path-String(): path doesn't exist and didn't appear upon re-mounting the network drives!"
			Throw $Remote_EventPathMissing_Error
			return $currentString
		}
		else {
			Write-PSFMessage -Level Debug -Message ("Success! Remote path " + $currentString + " exists after remount. Continuing.")
			return $currentString
		}
	}
	else {
		return $currentString
	}
}

function Get-Overseer-Video-Path-String()
{
	$currentBBID = Get-Current-BehavioralBoxID-From-Hostname
	$currentString = "I:\Videos\BB$($currentBBID)"
	if (! (Test-Path $currentString -IsValid)) {
		# Try to remount the network drive (I://) if needed.
		Write-PSFMessage -Level Debug -Message ("Remote path " + $currentString + " doesn't exist. Attempting to re-mount network drive I...")
		Invoke-Mount-Overseer-Network-Drive

		if (! (Test-Path $currentString -IsValid)) {
			$Remote_VideoPathMissing_Error = New-Object System.IO.DirectoryNotFoundException "Get-Overseer-Video-Path-String(): path doesn't exist and didn't appear upon re-mounting the network drives!"
			Throw $Remote_VideoPathMissing_Error
		}
		else {
			Write-PSFMessage -Level Important -Message ("Success! Remote path " + $currentString + " exists after remount. Continuing.")
			return $currentString
		}
	}
	else {
		return $currentString
	}
}

function Get-Local-Video-Path-String()
{
	$currentBBID = Get-Current-BehavioralBoxID-From-Hostname
	$currentString = "E:\$($currentBBID)" 
	if (! (Test-Path -isvalid $currentString)) {
		$LocalVideoPathMissing_Error = New-Object System.IO.DirectoryNotFoundException "Get-Local-Video-Path-String(): path doesn't exist!"
		Throw $LocalVideoPathMissing_Error
	}
	return $currentString
}

# function Fix-Path()
# {
# 	Set-Location FILESYSTEM::Z:
# }

function Upload-EventData()
{
	$completionSuccess = $false
	$localDataOutputPath = "C:\Common\data"
	try {
		$serverDataOutputPath = Get-Overseer-EventData-Path-String -ErrorAction Stop
		
		Write-PSFMessage -Level Debug -Message ('Upload-EventData: serverDataOutputPath: ' + $serverDataOutputPath)
		
	}
	catch {
		Write-PSFMessage -Level Warning -Message 'Error using Get-Overseer-EventData-Path-String in Upload-EventData().' -Tag 'Failure' -ErrorRecord $_
		$completionSuccess = $false
		return $completionSuccess
	}

	 try {
		# $serverDataOutputPath | Invoke-Robocopy -Path $localDataOutputPath -ArgumentList @('/e') -PassThru
		$RobocopyResult = Invoke-Robocopy -Path $localDataOutputPath -Destination @($serverDataOutputPath) -ArgumentList @('/e') -PassThru -EnableExit
		$OutputMessage = 'Exit code: ' + $RobocopyResult.ExitCode
		$OutputStandardMessage = ($RobocopyResult.StdOut -join [System.Environment]::NewLine)
		$OutputErrorMessage = ($RobocopyResult.StdErr -join [System.Environment]::NewLine)
		# ROBOCOPY $localDataOutputPath $serverDataOutputPath /e 
		Write-PSFMessage -Level Important -Message $OutputMessage -Tag 'Success'
		Write-PSFMessage -Level Debug -Message $OutputStandardMessage -Tag 'Output_STDOUT'
		Write-PSFMessage -Level Debug -Message $OutputErrorMessage -Tag 'Output_STDERR'
		if ($RobocopyResult.EncounteredError) {
			$completionSuccess = $false
		}
		else {
			$completionSuccess = $true
		}
		Write-PSFMessage -Level Important -Message 'Successfully performed ROBOCOPY Upload-EventData().' -Tag 'Success'
	}
	catch {
		Write-PSFMessage -Level Warning -Message 'Error performing ROBOCOPY Upload-EventData().' -Tag 'Failure' -ErrorRecord $_
		$completionSuccess = $false
	}
	return $completionSuccess
}

function Upload-Videos()
{
	$completionSuccess = $false
  	$localVideoPath = Get-Local-Video-Path-String
  	$serverVideoOutputPath = Get-Overseer-Video-Path-String
	try {
		# $serverVideoOutputPath | Invoke-Robocopy -Path $localVideoPath -ArgumentList @('/e') -PassThru
		$RobocopyResult = Invoke-Robocopy -Path $localVideoPath -Destination @($serverVideoOutputPath) -ArgumentList @('/e') -PassThru -EnableExit
		$OutputMessage = 'Exit code: ' + $RobocopyResult.ExitCode
		$OutputStandardMessage = ($RobocopyResult.StdOut -join [System.Environment]::NewLine)
		$OutputErrorMessage = ($RobocopyResult.StdErr -join [System.Environment]::NewLine)		
		# ROBOCOPY $localVideoPath $serverVideoOutputPath /e
		Write-PSFMessage -Level Important -Message $OutputMessage -Tag 'Success'
		Write-PSFMessage -Level Debug -Message $OutputStandardMessage -Tag 'Output_STDOUT'
		Write-PSFMessage -Level Debug -Message $OutputErrorMessage -Tag 'Output_STDERR'
		if ($RobocopyResult.EncounteredError) {
			$completionSuccess = $false
		}
		else {
			$completionSuccess = $true
		}
		Write-PSFMessage -Level Important -Message 'Successfully performed ROBOCOPY Upload-Videos().' -Tag 'Success'
	}
	catch {
		Write-PSFMessage -Level Warning -Message 'Error performing ROBOCOPY Upload-Videos().' -Tag 'Failure' -ErrorRecord $_
		$completionSuccess = $false
	}
	return $completionSuccess
}

function Upload-All()
{
	$exit_code = 0
	try {
		$completionSuccess_UploadEventData = Upload-EventData
		if (!$completionSuccess_UploadEventData) {
			$exit_code = 1
		}
		$completionSuccess_UploadVideos = Upload-Videos
		if (!$completionSuccess_UploadVideos) {
			$exit_code = 1
		}
		Write-PSFMessage -Level Important -Message 'Successfully performed all steps of Upload-All().' -Tag 'Success'
	}
	catch {
		Write-PSFMessage -Level Warning -Message 'Error performing a step of Upload-All().' -Tag 'Failure' -ErrorRecord $_
	}
	finally {
		Write-PSFMessage -Level Debug -Message '_________ Finished with UploadToOverseer.ps1 Powershell script.' -Tag 'End'
		Exit($exit_code)
	}
}

Write-PSFMessage -Level Debug -Message '=========== Starting UploadToOverseer.ps1 Powershell script.' -Tag 'Begin'

# Upload to the server
Upload-All

