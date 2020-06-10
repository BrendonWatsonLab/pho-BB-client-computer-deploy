<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	2/20/2020 2:02 PM
	 Created by:   	halechr
	 Organization: 	
	 Filename:     	PhoBehavioralBoxRemoteControl.psm1
	-------------------------------------------------------------------------
	 Module Name: PhoBehavioralBoxRemoteControl
	===========================================================================
#>

function Load-Remote-Computer-Info()
{
    Param($csv_path)
    Write-Output ('Reading remote hosts from CSV file: ' + $csv_path + '...')
    $csv_info = Import-Csv -Path $csv_path
    #Write-Output ('csv_info: ' + $csv_info)
	Write-Output ('    Done.')
	return $csv_info
}

## START General Network Functions:
function Get-Reverse-Hostname-Lookup-From-IP()
{
    Param($remote_desktop_address)
    #return nslookup $remote_desktop_address
    try { 
        return [system.net.dns]::gethostentry($remote_desktop_address)
    }
    catch {
      Write-Output ("Couldn't Resolve " + $remote_desktop_address)
      return '-'
    }
}

function Get-Address-From-Hostname()
{
    Param($remote_desktop_hostname)
    try { 
        return [System.Net.Dns]::GetHostAddresses($remote_desktop_hostname) | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
    }
    catch {
      Write-Output ("Couldn't Resolve " + $remote_desktop_hostname)
      return '-'
    }
}

# Adds the remote machine to the local TrustedHosts lists so it can be accessed via its IP address.
function Add-Remote-Machines-To-TrustedHosts()
{
    Param($remote_desktop_IPs)
    Write-Output ("Adding remote computers to local TrustedHosts...")
    $rowCount = $remote_desktop_IPs.Count;
    # Previous TrustedHosts:
    $curList = (Get-Item WSMan:\localhost\Client\TrustedHosts).value
    Write-Output ("    Initial TrustedHosts: " + $curList)

    # Clear TrustedHosts:
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "" -Force

    for ($loopindex=0; $loopindex -lt $rowCount; $loopindex++)
    {
        #$curList = (Get-Item WSMan:\localhost\Client\TrustedHosts).value
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value [string]$remote_desktop_IPs[$loopindex] -Force
        #Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value [string]$remote_desktop_IPs[$loopindex]
    }
    Write-Output("    Done.")
    # Updated TrustedHosts:
    $updatedList = (Get-Item WSMan:\localhost\Client\TrustedHosts).value
    Write-Output ("    Updated TrustedHosts: " + $updatedList)
}

function Invoke-Remote-UploadToOverseer()
{
    Param(
    [Parameter(Mandatory=$true)]
    [String[]]
    $remote_desktop_computer_names,

    [Parameter(Mandatory=$false)]
    [Switch]
    $EventData,

    [Parameter(Mandatory=$false)]
    [Switch]
    $VideoData
    )

    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
        #net use S: \\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare c474115B357 /user:RDE20007\watsonlabBB /persistent:yes
        #S:
        # Mount networks drives:
        #start-process "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\MapNetworkDrives.cmd"
        
        # Run the upload script:
        #start-process "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadDataToOverseer.bat"
        if ($EventData.IsPresent)
        {
            Write-Host "Uploading EventData to Overseer..." -ForeGroundColor Green
            #start-process "S:\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Upload\UploadEventDataToOverseer.bat"
            start-process "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Upload\UploadEventDataToOverseer.bat"
            Write-Host "    Done." -ForeGroundColor Green
        }

        if ($VideoData.IsPresent)
        {
            Write-Host "Uploading Videos to Overseer..." -ForeGroundColor Green
            #start-process "C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadVideosToOverseer.bat"
            start-process "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Upload\UploadVideosToOverseer.bat"
            
            Write-Host "    Done." -ForeGroundColor Green
        }

        # Run upload script
        #& C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1
        #Invoke-Item (start powershell ((Split-Path $MyInvocation.InvocationName) + "\C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Upload\UploadToOverseer.ps1"))

    }
}

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


# Sends a keypress event to the phoBehavioralBoxLabjackController software
function Send-PhoBB-Key()
{
    Param($key_letter)
    $wshell = New-Object -ComObject wscript.shell;
    $wshell.AppActivate('phoBehavioralBoxLabjackController')
    Sleep 1
    $wshell.SendKeys($key_letter)
    
}

function Send-PhoBB-Key-Quit()
{
    Send-PhoBB-Key -key_letter 'q'    
}

