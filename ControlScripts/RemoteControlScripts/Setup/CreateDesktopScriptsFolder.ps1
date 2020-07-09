#Import-Module -Name C:\myRandomDirectory\myModule -Verbose
# Import-Module -Name C:\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Helpers\Modules\PhoBehavioralBoxRemoteControl
Import-Module -Name C:\Common\repo\pho-BB-client-computer-deploy\DeployToClient\Helpers\Modules\PhoBehavioralBoxRemoteControl




function Invoke-Remote-Copy-Latest-Installers()
{
    Param(
        [Parameter(Mandatory=$true)]
        [String[]]
        $remote_desktop_computer_names
    )


    $LatestInstallerPath = 'C:\BehavioralBoxServerShare\Behavioral Box Computer Setup - 9-5-2019\Combined Installer\Combined Installer\4 - Auto\Install phoBehavioralBoxLabjackController.exe'
    foreach ($_ in $remote_desktop_computer_names)
        {Copy-Item $LatestInstallerPath -Destination \\$_\$Destination -Recurse -PassThru}

    <#
    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}

        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $FolderPath = Join-Path $DesktopPath 'Setup'
        New-Item $FolderPath -ItemType Directory




        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }
    #>
#    return $results
}


function Invoke-Remote-Create-Desktop-Setup-Folder()
{
    Param(
        [Parameter(Mandatory=$true)]
        [String[]]
        $remote_desktop_computer_names
    )

    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}

        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $FolderPath = Join-Path $DesktopPath 'Setup'
        New-Item $FolderPath -ItemType Directory

        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }

    return $results
}

function Invoke-Remote-Create-Desktop-Scripts-Folder()
{
    Param(
        [Parameter(Mandatory=$true)]
        [String[]]
        $remote_desktop_computer_names
    )
    #Param($remote_desktop_computer_names)

    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}

        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $ScriptsFolderPath = Join-Path $DesktopPath 'Scripts'
        New-Item $ScriptsFolderPath -ItemType Directory

        #$props.Add('DesktopPath',$DesktopPath)

        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }

    return $results
}

function Invoke-Remote-Install-Logging-Framework-Folder()
{
    Param(
        [Parameter(Mandatory=$true)]
        [String[]]
        $remote_desktop_computer_names
    )
    #Param($remote_desktop_computer_names)

    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        #$props = @{ComputerName=$env:COMPUTERNAME}

        #Install-Module PSFramework
        #Set-PSFLoggingProvider -Name logfile -Enabled $true -FilePath 'C:\Common\info\UploadScript.log'


        #$props.Add('DesktopPath',$DesktopPath)

        # Return the output object
        #New-Object -Type PSObject -Prop $Props 
    }

    #return $results
}

function Test-CSV-Hosts()
{
    # $active_csv_path = "G:\Google Drive\Modern Behavior Box\Documentation\Computers Info\BB Computer Info Spreadsheet - Export.csv"
    $active_csv_path = 'C:\Users\WatsonLab\Desktop\RDP Info\BB Computer Info Spreadsheet - Export.csv'

    # Loads from CSV
    $loaded_csv_info = Load-Remote-Computer-Info -csv_path $active_csv_path
    $active_csv_info = $loaded_csv_info

    # Enable Filtering for specify hosts:
#    $filtered_loaded_csv_info = $loaded_csv_info | Where Hostname -match WATSON-BB-1 | Where Hostname -notmatch WATSON-BB-10
     #$active_csv_info = $filtered_loaded_csv_info

#     $active_csv_info
     # Display in table:
     $active_csv_info | Sort-Object Hostname | Format-Table -AutoSize

    # Get a string array of the target names
    $target_array = $active_csv_info.IP
   
    # Get Hostnames from IPs:
    $recovered_host_records = $target_array | ForEach-Object {Get-Reverse-Hostname-Lookup-From-IP -remote_desktop_address $_}
    $recovered_hostnames = $recovered_host_records.HostName
    # Get fully resolved network addresses from recovered host names:
    $final_network_addresses = $recovered_hostnames | ForEach-Object {Get-Address-From-Hostname -remote_desktop_hostname $_}

    # Add remote machines to the local TrustedHosts list so it can be accessed via its IP address.:
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

    ## Creates Remote Folders:
#    $results = Invoke-Remote-Create-Desktop-Scripts-Folder -remote_desktop_computer_names $recovered_hostnames
#    $results

    # $results = Invoke-Remote-Create-Desktop-Setup-Folder -remote_desktop_computer_names $recovered_hostnames
    # $results

    #$results = Invoke-Remote-Install-Logging-Framework-Folder -remote_desktop_computer_names $recovered_hostnames
    $results = Invoke-Remote-Install-Logging-Framework-Folder -remote_desktop_computer_names $final_network_addresses
    $results
}


Test-CSV-Hosts