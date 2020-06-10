#Import-Module -Name C:\myRandomDirectory\myModule -Verbose
Import-Module -Name C:\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Helpers\Modules\PhoBehavioralBoxRemoteControl

function Invoke-Remote-SendPhoBBSafeShutdown()
{
    Param(
    [Parameter(Mandatory=$true)]
    [String[]]
    $remote_desktop_computer_names
    )

    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -ScriptBlock {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
        # Send-PhoBB-Key-Quit
        $wshell = New-Object -ComObject wscript.shell;
        $wshell.AppActivate('phoBehavioralBoxLabjackController')
        Sleep 1
        #$wshell.SendKeys('q')
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.SendKeys]::SendWait('q');

    }
    return $results
}

function Test-CSV-Hosts()
{
    $active_csv_path = "G:\Google Drive\Modern Behavior Box\Documentation\Computers Info\BB Computer Info Spreadsheet - Export.csv"
    
    # Loads from CSV
    $loaded_csv_info = Load-Remote-Computer-Info -csv_path $active_csv_path
    $active_csv_info = $loaded_csv_info

    # Enable Filtering for specify hosts:
#    $filtered_loaded_csv_info = $loaded_csv_info | Where Hostname -match WATSON-BB-1 | Where Hostname -notmatch WATSON-BB-10
     #$active_csv_info = $filtered_loaded_csv_info

#     $active_csv_info
    # Display in table:
    # $active_csv_info | Sort-Object Hostname | Format-Table -AutoSize

    # Get a string array of the target names
    $target_array = $active_csv_info.IP
   
    # Get Hostnames from IPs:
    $recovered_host_records = $target_array | ForEach-Object {Get-Reverse-Hostname-Lookup-From-IP -remote_desktop_address $_}
    $recovered_hostnames = $recovered_host_records.HostName
    # Get fully resolved network addresses from recovered host names:
    $final_network_addresses = $recovered_hostnames | ForEach-Object {Get-Address-From-Hostname -remote_desktop_hostname $_}

    # Add remote machines to the local TrustedHosts list so it can be accessed via its IP address.:
    Write-Output "Updating TrustedHosts..."
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force


    Invoke-Remote-SendPhoBBSafeShutdown -remote_desktop_computer_names $recovered_hostnames
    Write-Output "Done."
}


Test-CSV-Hosts