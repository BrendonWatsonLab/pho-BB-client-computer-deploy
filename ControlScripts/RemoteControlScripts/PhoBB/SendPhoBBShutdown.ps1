#Import-Module -Name C:\myRandomDirectory\myModule -Verbose
Import-Module -Name C:\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\DeployToClient\Helpers\Modules\PhoBehavioralBoxRemoteControl


## A version that gets running process IDs for all BB software at once.
function Invoke-Remote-Get-BB-Client-Software-Processes()
{
    Param($remote_desktop_computer_names)
    Write-Output ("Getting Remote BB Client Computer Software Processes...")
    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}
        # Check for running phoBehavioralBoxLabjackController processes
        try {
            $potentially_running_process = Get-Process phoBehavioralBoxLabjackController -ErrorAction Stop
            $props.Add('phoBehavioralBoxLabjackController_Running',$True)
            $props.Add('phoBehavioralBoxLabjackController_ProcessID', $potentially_running_process.Id)
        }  
        catch {
            $props.Add('phoBehavioralBoxLabjackController_Running',$False)
            $props.Add('phoBehavioralBoxLabjackController_ProcessID','-')
        }

        # Check for running OBS Video software processes
        try {
            $potentially_running_process = Get-Process obs64 -ErrorAction Stop
            $props.Add('OBS_Running',$True)
            $props.Add('OBS_ProcessID', $potentially_running_process.Id)
        }  
        catch {
            $props.Add('OBS_Running',$False)
            $props.Add('OBS_ProcessID','-')
        }

        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }

    return $results
}

function Invoke-Remote-Quit-BB-Client-Software-Processes()
{
    Param(
        [Parameter(Mandatory=$true)]
        [String[]]
        $remote_desktop_computer_names,
    
        [Parameter(Mandatory=$false)]
        [Switch]
        $EnableForPhoBB,
    
        [Parameter(Mandatory=$false)]
        [Switch]
        $EnableForOBS
    )
    #Param($remote_desktop_computer_names)

    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}

        if ($EnableForPhoBB.IsPresent)
        {
            # Check for running phoBehavioralBoxLabjackController processes
            try {
                $potentially_running_process = Get-Process phoBehavioralBoxLabjackController -ErrorAction Stop
                $props.Add('phoBehavioralBoxLabjackController_WasRunning',$True)
                # Quit the process
                $potentially_running_process | Foreach-Object { $_.CloseMainWindow() | Out-Null } | stop-process –force
                $props.Add('phoBehavioralBoxLabjackController_Terminated',$True)
            }  
            catch {
                $props.Add('phoBehavioralBoxLabjackController_WasRunning',$False)
                $props.Add('phoBehavioralBoxLabjackController_Terminated',$False)
            }
        }

        
        if ($EnableForOBS.IsPresent)
        {
            # Check for running OBS Video software processes
            try {
                $potentially_running_process = Get-Process obs64 -ErrorAction Stop
                $props.Add('OBS_WasRunning',$True)
                # Quit the process
                $potentially_running_process | Foreach-Object { $_.CloseMainWindow() | Out-Null } | stop-process –force
                $props.Add('OBS_Terminated',$True)
            }  
            catch {
                $props.Add('OBS_WasRunning',$False)
                $props.Add('OBS_Terminated',$False)
            }
        }

        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }

    return $results
}

function Command-Quit-BB-Software()
{
    Param($remote_desktop_computer_names)
    $bb_software_quit_results = Invoke-Remote-Quit-BB-Client-Software-Processes -remote_desktop_computer_names $remote_desktop_computer_names  -EnableForPhoBB
    $bb_software_quit_results_formatted = $bb_software_quit_results | Select-Object -Property ComputerName, phoBehavioralBoxLabjackController_WasRunning, phoBehavioralBoxLabjackController_Terminated, OBS_WasRunning, OBS_Terminated | Sort-Object -Property ComputerName
    return $bb_software_quit_results_formatted
}

function Command-Get-Running-BB-Software()
{
    Param($remote_desktop_computer_names)
    $bb_software_status_results = Invoke-Remote-Get-BB-Client-Software-Processes -remote_desktop_computer_names $remote_desktop_computer_names
    $bb_software_status_results_formatted = $bb_software_status_results | Select-Object -Property ComputerName, phoBehavioralBoxLabjackController_Running, phoBehavioralBoxLabjackController_ProcessID, OBS_Running, OBS_ProcessID | Sort-Object -Property ComputerName
    return $bb_software_status_results_formatted
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

    ## Quits all software
    $quit_results = Command-Quit-BB-Software -remote_desktop_computer_names $recovered_hostnames
    # Inline Table View:
    $quit_results | Format-Table -AutoSize
    
}


Test-CSV-Hosts