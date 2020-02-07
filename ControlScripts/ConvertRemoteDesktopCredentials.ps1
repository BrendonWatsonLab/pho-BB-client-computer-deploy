# Pho Hale 1/21/2020, 3:00pm

Install-Module BetterCredentials -AllowClobber


function Get-Credentials-With-Wrong-Username()
{
  # Find credentials with the invalid UMHS username prefix:
  $old_creds = Find-Credential | Where UserName -match UMHS\watsonlab
  return $old_creds
}

function Get-RemoteDesktop-Credentials()
{
  $old_creds = Find-Credential TERMSRV/*
  return $old_creds
}

function Get-RemoteDesktop-Credentials-With-Wrong-Type()
{
  $old_creds = Get-RemoteDesktop-Credentials | Where Type -match DomainPassword
  return $old_creds
}

function Get-RemoteDesktop-Credentials-With-Correct-Type()
{
  $old_creds = Get-RemoteDesktop-Credentials | Where Type -match Generic
  return $old_creds
}

function Get-Direct-Watson-BB-Credentials-With-Wrong-Type()
{
  $old_creds = Find-Credential WATSON-BB-* | Where Type -match DomainPassword
  return $old_creds
}

# Find-Credential
# Find-Credential TERMSRV/*
# Find-Credential | Where UserName -match User@Example.org
# Find-Credential | Where Type -match DomainPassword


# Unfinished.
function Fix-Credentials-With-Wrong-Username()
{
  # Fix UMHS username prefix:
  $old_creds = Get-Credentials-With-Wrong-Username
    foreach($an_old_cred in $old_creds)
    {
        Write-Output ('Credential ' + $an_old_cred.Target + ' of credential-type ' + $an_old_cred.Type + ' is attempting to be converted into a Generic-type credential.')
        $an_old_cred.UserName

        Set-Credential -Credential $an_old_cred -Target $an_old_cred.Target -
        #Remove-Credential -Target $an_old_cred.Target -Type DomainPassword
        #BetterCredentials\Get-Credential
        #Write-Output ('Done. ' + $an_old_cred.Target + ' type: ' + $an_old_cred.Type)
    }
}

function Load-Remote-Computer-Info()
{
    Param($csv_path)
    Write-Output ('Reading credentials from CSV file: ' + $csv_path + '...')
    $csv_info = Import-Csv -Path $csv_path
    Write-Output ('csv_info: ' + $csv_info)
    return $csv_info
}

function Save-Remote-Computer-Info()
{
    Param($csv_path, $old_creds)

    # Clearing CSV file:
    #"" | Export-Csv -Path $csv_path -NoTypeInformation
    Clear-Content -Path $csv_path
    # Write each credential to the file:
    foreach($an_old_cred in $old_creds)
    {
        $an_old_cred | Select-Object -Property Target,TargetAlias,Type,Persistence,Description,LastWriteTime,UserName,Password | Export-Csv -Path $csv_path -NoTypeInformation -Append
    }
    Write-Output ('Saved credentials to CSV file: ' + $csv_path + '.')
}


function Create-Generic-Credentials()
{
    Param($old_creds)
    foreach($an_old_cred in $old_creds)
    {
        Set-Credential -Credential $an_old_cred -Target $an_old_cred.Target -Type Generic
        Write-Output ('Created ' + $an_old_cred.Target + ' of credential-type Generic')
    }

}

function Remove-Old-Credentials()
{
    Param($old_creds)
    foreach($an_old_cred in $old_creds)
    {
        Remove-Credential -Target $an_old_cred.Target -Type DomainPassword
        Write-Output ('Removed ' + $an_old_cred.Target + ' of credential-type ' + $an_old_cred.Type)
    }

}

function Get-Computer-Hostname()
{
    return $env:computername    
}

# Accepts a string like "TERMSRV/WATSON-BB-OVERS" and returns "WATSON-BB-OVERS"
function Get-Network-Address-From-Termserv-Address()
{
    Param($remote_desktop_address)
    $prefix_string = "TERMSRV/"
    $remoteOnlyName = $remote_desktop_address.Replace($prefix_string,"")
    return $remoteOnlyName
}


# Generally reusable network functions:
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


#[system.net.dns]::gethostentry('10.17.152.64')
#[system.net.dns]::gethostentry('watson-bb-01.med.umich.edu')
#[system.net.dns]::gethostentry('WATSON-BB-OVERS')

# $old_creds = Get-Credentials-With-Wrong-Username
# $old_creds = Get-Direct-Watson-BB-Credentials-With-Wrong-Type
# $old_creds = Get-RemoteDesktop-Credentials-With-Wrong-Type

# From the credentials with the wrong type, create those with the correct type (Generic).
# Create-Generic-Credentials -old_creds $old_creds
# Remove the old credentials with the wrong type
# Remove-Old-Credentials -old_creds $old_creds


function Test-CSV-Hosts()
{
    $active_csv_path = "G:\Google Drive\Modern Behavior Box\Documentation\Computers Info\RDP Info\RdpCredentials.csv"
    $active_enhanced_csv_path = "G:\Google Drive\Modern Behavior Box\Documentation\Computers Info\RDP Info\RdpCredentials_enhanced.csv"
    $curr_creds = Get-RemoteDesktop-Credentials-With-Correct-Type

    # Saves out to CSV:
    Save-Remote-Computer-Info -csv_path $active_csv_path -old_creds $curr_creds


    $loaded_csv_info = Load-Remote-Computer-Info -csv_path $active_csv_path

    <#
    $loaded_csv_info.Foreach({$element})
    $loaded_csv_info | ForEach-Object {$_.Target}
    $target_array = $loaded_csv_info | ForEach-Object {$_.Target}
    $target_array = [System.Collections.Generic.List[string]]$target_array
    New-Variable -Name "target_array" -Value $loaded_csv_info | ForEach-Object {$_.Target}
    #>
    # Get a string array of the target names
    # $target_array = $loaded_csv_info.Target
    $target_array = $loaded_csv_info.Target
    #$short_target_array = Get-Network-Address-From-Termserv-Address -remote_desktop_address $target_array

    $short_target_array = $target_array  | ForEach-Object {Get-Network-Address-From-Termserv-Address -remote_desktop_address $_}
    #$short_target_array

    $recovered_host_records = $short_target_array | ForEach-Object {Get-Reverse-Hostname-Lookup-From-IP -remote_desktop_address $_}
    $recovered_hostnames = $recovered_host_records.HostName

    $final_network_addresses = $recovered_hostnames | ForEach-Object {Get-Address-From-Hostname -remote_desktop_hostname $_}

    

    # Build output objects:
    # Create the columns for the CSV File
    #$H1='HostNames'
    #$H2='NetworkAddress'


    $final_network_addresses

    # Add the columns into a variable that will be used to add data
    #$row = "" | Select-Object $H1,$H2
    $rowCount = $target_array.Count;

    #create array used to capture hostname, mac and ip address
    $outarray = @()

    for ($loopindex=0; $loopindex -lt $rowCount; $loopindex++)
    {
        $outarray += New-Object PsObject -property @{
            'HostName' = $recovered_hostnames[$loopindex]
            'IP' = [string]$final_network_addresses[$loopindex]
        }
    }
    
    <#
    $obj = new-object PSObject
    $obj | add-member -membertype NoteProperty -name "One" -value "1"
    $obj | add-member -membertype NoteProperty -name "Two" -value "2"
    $obj | add-member -membertype NoteProperty -name "Three" -value "3"
    $obj | export-csv sample.csv -notypeinformation
    #>

    # Write to CSV
    Clear-Content -Path $active_enhanced_csv_path

    #export to .csv file
    $outarray | Export-Csv -Path $active_enhanced_csv_path -NoTypeInformation -Append
    # Format-Table ProcessName, @{Label="TotalRunningTime"; Expression={(Get-Date) - $_.StartTime}}


}


<#
foreach($an_old_cred in $old_creds)
{
    Write-Output ('Credential ' + $an_old_cred.Target + ' of credential-type ' + $an_old_cred.Type + ' is attempting to be converted into a Generic-type credential.')
    #$csv_output_string = $an_old_cred | Select-Object -Property Target,TargetAlias,Type,Persistence,Description,LastWriteTime,UserName,Password
    #$an_old_cred | Select-Object -Property Target,TargetAlias,Type,Persistence,Description,LastWriteTime,UserName,Password

    #$an_old_cred | Select-Object -Property Target,TargetAlias,Type,Persistence,Description,LastWriteTime,UserName,Password | Export-Csv -Path "G:\Google Drive\Modern Behavior Box\Documentation\Computers Info\RDP Info\RdpCredentials.csv" -NoTypeInformation -Append


    #Write-Output ('Output string: ' + $csv_output_string)
    #$an_old_cred | Select-Object -Property Target,TargetAlias,Type,Persistence,Description,LastWriteTime,UserName,Password | Export-Csv -Path .\WmiData.csv -NoTypeInformation

    #$an_old_cred.Type = 'Generic'
    #Set-Credential -Credential $an_old_cred

    #Set-Credential -Credential $an_old_cred -Target $an_old_cred.Target -Type Generic -Persistence LocalComputer -Description $an_old_cred.Description
    #Set-Credential -Credential $an_old_cred -Target $an_old_cred.Target -Type Generic

    Remove-Credential -Target $an_old_cred.Target -Type DomainPassword
    #Write-Output ('Done. ' + $an_old_cred.Target + ' type: ' + $an_old_cred.Type)
}

#Remove-Credential -Target "TERMSRV/10.17.152.172" -Type DomainPassword
#>


Test-CSV-Hosts


<#
$ip = [System.Net.Dns]::GetHostAddresses("watson-bb-01.med.umich.edu")[0]

Resolve-DnsName watson-bb-overs | FT Name, IPAddress -HideTableHeaders
#watson-bb-overs 10.17.158.49
#watson-bb-overs 192.168.84.1
#watson-bb-overs 192.168.10.1

Resolve-DnsName computername | FT Name, IPAddress -HideTableHeaders | Out-File -Append c:\filename.txt



[System.Net.Dns]::GetHostAddresses("watson-bb-overs") | foreach { $_.IPAddressToString | findstr "10.3."}
Get-Computer-Hostname
[System.Net.Dns]::GetHostAddresses($computername)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }

[System.Net.Dns]::GetHostAddresses($computername)  | where {$_.AddressFamily -notlike "InterNetworkV6"} | foreach {echo $_.IPAddressToString }
#>