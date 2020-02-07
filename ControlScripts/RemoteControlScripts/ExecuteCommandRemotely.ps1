# Execute Remote:
# Install:
Install-Module -Name Invoke-CommandAs

function Load-Remote-Computer-Info()
{
    Param($csv_path)
    Write-Output ('Reading remote hosts from CSV file: ' + $csv_path + '...')
    $csv_info = Import-Csv -Path $csv_path
    Write-Output ('csv_info: ' + $csv_info)
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

function Get-Computer-Hostname()
{
    return $env:computername    
}
## END General Network Functions


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




# Pings provided hosts to see if they're up
function Ping-Remote-Computers()
{
    Param($RemoteComputers)
    Write-Output ("Pinging remote computers:")
    Test-Connection -ComputerName $RemoteComputers -Quiet
    #Test-Connection -ComputerName $RemoteComputers
    <#
    If (Test-Connection -ComputerName $RemoteComputers -Quiet)
    {
         Invoke-Command -ComputerName $RemoteComputers -ScriptBlock {Get-ChildItem “C:\Program Files”}
    }
    #>
    Write-Output("    Done.")
}

function Invoke-Remote-Command()
{
    Param($remote_desktop_computer_names)
    # Execute Remotely on multiple Computers at the same time.
    # Invoke-CommandAs -ComputerName 'VM01', 'VM02' -Credential $Credential -ScriptBlock { Get-Process }

    # Note: To use direct IPs, look into winrm help config
    <#
    [10.17.152.217] Connecting to remote server 10.17.152.217 failed with the following error message : The WinRM client cannot process the request. Default authentication may be used with an IP address under the following conditions: the transport is HTTPS or 
the destination is in the TrustedHosts list, and explicit credentials are provided. Use winrm.cmd to configure TrustedHosts. Note that computers in the TrustedHosts list might not be authenticated. For more information on how to set TrustedHosts run the 
following command: winrm help config. For more information, see the about_Remote_Troubleshooting Help topic.
    + CategoryInfo          : OpenError: (10.17.152.217:String) [], PSRemotingTransportException
    + FullyQualifiedErrorId : CannotUseIPAddress,PSSessionStateBroken
    #>

    #Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential $Credential -RunElevated -ScriptBlock { Get-Process }
    #Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock { Get-Process }

    #Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock { msiexec.exe /i \\10.17.158.49\ClientDeployables\SpiceworksAgentShell_Collection_Agent.msi /qn SITE_KEY="7Q5lNErjMplXI_-B_zAN" }

    Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock { Get-Process phoBehavioralBoxLabjackController | Foreach-Object { $_.CloseMainWindow() | Out-Null } | stop-process –force }
}



#### REMOTE COMMANDS ##


function Invoke-Remote-Get-BBLabjackControlerProcess()
{
    Param($remote_desktop_computer_names)
    Write-Output ("Getting Remote BB Labjack Controller Processes...")
    #$results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock { Get-Process phoBehavioralBoxLabjackController }
    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}
        
        try {
            $potentially_running_process = Get-Process phoBehavioralBoxLabjackController -ErrorAction Stop
            #Write-Host "The Set-CASMailbox command completed correctly"
            $props.Add('Is_Running',$True)
            $props.Add('ProcessID', $potentially_running_process.Id)
            #$props.Add('Version', $potentially_running_process.ProductVersion)
        }  
        catch {
            Write-Host "The phoBehavioralBoxLabjackController software is not running on computer " + $env:COMPUTERNAME  -ForegroundColor Red
            $props.Add('Is_Running',$False)
            $props.Add('ProcessID','Not running!')
        }

        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }

    Write-Output("    Done.")
    return $results
}

function Invoke-Remote-Get-OBS-Video-Process()
{
    Param($remote_desktop_computer_names)
    Write-Output ("Getting Remote BB OBS Video Software Processes...")
    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}
        try {
            $potentially_running_process = Get-Process obs64 -ErrorAction Stop
            $props.Add('Is_Running',$True)
            $props.Add('ProcessID', $potentially_running_process.Id)
            #$props.Add('Version', $potentially_running_process.ProductVersion)
        }  
        catch {
            #Write-Host "The phoBehavioralBoxLabjackController software is not running on computer " + $env:COMPUTERNAME  -ForegroundColor Red
            $props.Add('Is_Running',$False)
            $props.Add('ProcessID','Not running!')
        }

        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }

    Write-Output("    Done.")
    return $results
}


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


## Quits the BB Client Software
function Invoke-Remote-Quit-BB-Client-Software-Processes()
{
    Param($remote_desktop_computer_names)
    $results = Invoke-CommandAs -ComputerName $remote_desktop_computer_names -Credential watsonlab -RunElevated -ScriptBlock {
        $props = @{ComputerName=$env:COMPUTERNAME}
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

        # Return the output object
        New-Object -Type PSObject -Prop $Props 
    }

    return $results
}

function Command-Quit-BB-Software()
{
    Param($remote_desktop_computer_names)
    $bb_software_quit_results = Invoke-Remote-Quit-BB-Client-Software-Processes -remote_desktop_computer_names $remote_desktop_computer_names
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
    $computer_hostname = Get-Computer-Hostname
    $computer_hostname

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

    #$recovered_hostnames
    
    # Add remote machines to the local TrustedHosts list so it can be accessed via its IP address.:
    #Add-Remote-Machines-To-TrustedHosts -remote_desktop_IPs $final_network_addresses
    #Add-Remote-Machines-To-TrustedHosts -remote_desktop_IPs $recovered_hostnames
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

    # Check connections to remote computers:
    #Ping-Remote-Computers -RemoteComputers $recovered_hostnames

    #Set-Service WinRM -ComputerName $recovered_hostnames -startuptype Automatic

    # Run Remote Commands:
    $export_remote_command_results_folder = "C:\BehavioralBoxServerShare\BB-Computer-Deploy-01-21-2020\ControlScripts\RemoteControlScripts\Results"

    #Invoke-Remote-Command -remote_desktop_computer_names $final_network_addresses
    #Invoke-Remote-Command -remote_desktop_computer_names $recovered_hostnames

    <#
    $obs_status_results = Invoke-Remote-Get-OBS-Video-Process -remote_desktop_computer_names $recovered_hostnames
    $obs_result_name = "status_OBS_Video_Software"
    $obs_result_export_csv_path = $export_remote_command_results_folder + "\" + $obs_result_name + ".csv"
    $obs_status_results | Select-Object -Property ComputerName, Is_Running, ProcessID | Sort-Object -Property ComputerName | Out-GridView -Title "Client BB Computer Status: OBS Video software" -PassThru | Export-Csv -Path $obs_result_export_csv_path
    #>

    <#
    # Get phoBehavioralBoxLabjackController running status:
    $phoBBLabjackController_status_results = Invoke-Remote-Get-BBLabjackControlerProcess -remote_desktop_computer_names $recovered_hostnames
    # Opens the results in a GUI Out-GridView (table like) window and also exports them to a CSV file
    $phoBB_result_name = "status_phoBehavioralBoxLabjackController"
    $phoBB_result_export_csv_path = $export_remote_command_results_folder + "\" + $phoBB_result_name + ".csv"
    $phoBBLabjackController_status_results | Select-Object -Property ComputerName, Is_Running, ProcessID | Sort-Object -Property ComputerName | Out-GridView -Title "Client BB Computer Status: phoBehavioralBoxLabjackController software" -PassThru | Export-Csv -Path $phoBB_result_export_csv_path
    #>

    

    ## Quits all software
    $quit_results = Command-Quit-BB-Software -remote_desktop_computer_names $recovered_hostnames
    $bb_software_result_name = "quit_All_Client_Software"
    $bb_software_result_export_csv_path = $export_remote_command_results_folder + "\" + $bb_software_result_name + ".csv"
    
    # GUI Grid View:
    #$quit_results | Out-GridView -Title "Client BB Computer Quit: All Custom BB software" -PassThru | Export-Csv -Path $bb_software_result_export_csv_path
    # Inline Table View:
    $quit_results | Export-Csv -Path $bb_software_result_export_csv_path
    $quit_results | Format-Table -AutoSize


    # Gets all software status
    $bb_software_status_results = Command-Get-Running-BB-Software -remote_desktop_computer_names $recovered_hostnames
    $bb_software_result_name = "status_All_Client_Software"
    $bb_software_result_export_csv_path = $export_remote_command_results_folder + "\" + $bb_software_result_name + ".csv"
    # GUI Grid View:
    #$bb_software_status_results | Out-GridView -Title "Client BB Computer Status: All Custom BB software" -PassThru | Export-Csv -Path $bb_software_result_export_csv_path
    # Inline Table View:
    $bb_software_status_results | Export-Csv -Path $bb_software_result_export_csv_path
    $bb_software_status_results | Format-Table -AutoSize

}




Test-CSV-Hosts

