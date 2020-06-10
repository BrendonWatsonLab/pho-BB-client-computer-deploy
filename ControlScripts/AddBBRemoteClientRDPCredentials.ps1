##########
# AddBBRemoteClientRDPCredentials
# Primary Author: Pho Hale <PhoHale@gmail.com>
# Version: 1.0.0, 1/21/2020, 3:00pm

##########

Install-Module BetterCredentials -AllowClobber

function Load-Remote-Computer-Info()
{
    Param($csv_path)
    Write-Output ('Reading remote hosts from CSV file: ' + $csv_path + '...')
    $csv_info = Import-Csv -Path $csv_path
    Write-Output ('csv_info: ' + $csv_info)
    return $csv_info
}

function Build-Client-BBIDs()
{
    # Build an array of BBIDs like "BB01", "BB02", ...
    $outputStrings = @()
    $numberOfBehavioralBoxComputers = 16
    for ($boxID = 1; $boxID -lt ($numberOfBehavioralBoxComputers + 1); $boxID++) {
        $currString = "BB{0:d2}" -f $boxID
        $outputStrings += @($currString)
    }
    return $outputStrings
}

function Build-Client-BB-Hostnames()
{

    # Build arrays of hostnames and full hostnames
    $hostnameStrings = @()
    $fullStrings = @()
    $numberOfBehavioralBoxComputers = 16
    for ($boxID = 1; $boxID -lt ($numberOfBehavioralBoxComputers + 1); $boxID++) {
        $currName = "WATSON-BB-{0:d2}" -f $boxID
        $currFullName = "WATSON-BB-{0:d2}.med.umich.edu" -f $boxID
        $hostnameStrings += @($currName)
        $fullStrings += @($currFullName)
    }
    return $hostnameStrings
}

function Build-Client-BB-FullyResolvedHostnames()
{

    # Build arrays of hostnames and full hostnames
    $hostnameStrings = @()
    $fullStrings = @()
    $numberOfBehavioralBoxComputers = 16
    for ($boxID = 1; $boxID -lt ($numberOfBehavioralBoxComputers + 1); $boxID++) {
        $currName = "WATSON-BB-{0:d2}" -f $boxID
        $currFullName = "WATSON-BB-{0:d2}.med.umich.edu" -f $boxID
        $hostnameStrings += @($currName)
        $fullStrings += @($currFullName)
    }
    return $fullStrings
}

#function Find-Credentials-Matching-Client-Names()
function Build-Ideal-Client-Credentials()
{
    Write-Output "Build-Ideal-Client-Credentials..."
    $hostnames = Build-Client-BB-Hostnames
    $fully_resolved_hostnames = Build-Client-BB-FullyResolvedHostnames

    $rowCount = $hostnames.Count;

    for ($loopindex=0; $loopindex -lt $rowCount; $loopindex++)
    {
        $curr_hostname = $hostnames[$loopindex]
        $curr_fully_resolved_hostname = $fully_resolved_hostnames[$loopindex]

        $curr_hostname_RDP = Get-Termserv-Address-From-Network-Address -remote_desktop_address $curr_hostname
        $curr_fully_resolved_hostname_RDP = Get-Termserv-Address-From-Network-Address -remote_desktop_address $curr_fully_resolved_hostname

        # Create the credentials:
        Create-Standard-Credential -target_name $curr_hostname
        Create-Standard-Credential -target_name $curr_fully_resolved_hostname
        Create-Standard-Credential -target_name $curr_hostname_RDP
        Create-Standard-Credential -target_name $curr_fully_resolved_hostname_RDP

        Try
        {
            # -ErrorAction Stop
            $resolvedDNSObj = Resolve-DnsName -Name $aFullHostname -ErrorAction Stop
            $curr_foundIP = $resolvedDNSObj.IPAddress
            $curr_foundIP_RDP = Get-Termserv-Address-From-Network-Address -remote_desktop_address $curr_foundIP

            Create-Standard-Credential -target_name $curr_foundIP
            Create-Standard-Credential -target_name $curr_foundIP_RDP
        }
        Catch
        {
            Write-Output ("Couldn't Resolve IP for " + $curr_fully_resolved_hostname)
            #Break
        }

        Write-Output ('Created credentials for ' + $curr_fully_resolved_hostname)
    }

    Write-Output "    Done."
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

# Accepts a string like "TERMSRV/WATSON-BB-OVERS" and returns "WATSON-BB-OVERS"
function Get-Network-Address-From-Termserv-Address()
{
    Param($remote_desktop_address)
    $prefix_string = "TERMSRV/"
    $remoteOnlyName = $remote_desktop_address.Replace($prefix_string,"")
    return $remoteOnlyName
}

# Accepts a string like "WATSON-BB-OVERS" and returns"TERMSRV/WATSON-BB-OVERS"
function Get-Termserv-Address-From-Network-Address()
{
    Param($remote_desktop_address)
    $prefix_string = "TERMSRV/"
    $termsrvName = "$($prefix_string)$($remote_desktop_address)"
    return $termsrvName
}

## END General Network Functions





## START Credential Management Functions:
function Get-RemoteDesktop-Credentials()
{
  $old_creds = Find-Credential TERMSRV/*
  return $old_creds
}

function Get-Direct-Watson-BB-Credentials()
{
  $old_creds = Find-Credential WATSON-BB-*
  return $old_creds
}

function Get-RDP-Watson-BB-Credentials()
{
  $old_creds = Find-Credential TERMSRV/WATSON-BB-*
  return $old_creds
}


function Create-Standard-Credential()
{
    Param($target_name)
    #BetterCredentials\Get-Credential $target_name -UserName watsonlab -Password cajal1852 -GenericCredentials -Force -Store
    BetterCredentials\Get-Credential -Target $target_name -UserName watsonlab -Password cajal1852 -GenericCredentials -Force -Store
    #BetterCredentials\Get-Credential $target_name -Delete -Store
}

function Create-Generic-Credentials()
{
    Param($hostnames)
    foreach($a_hostname in $hostnames)
    {
        # -Inline
        Set-Credential $a_hostname -Type Generic -Password cajal1852
        Write-Output ('Created credential for ' + $a_hostname + ' of credential-type Generic.')
    }
}

function Remove-Old-Credentials()
{
    Param($hostnames)
    foreach($a_hostname in $hostnames)
    {
        Remove-Credential -Target $a_hostname.Target -Type DomainPassword
        Write-Output ('Removed ' + $a_hostname.Target + ' of credential-type ' + $a_hostname.Type)
    }

}

function Update-Credentials()
{
    Param($hostnames)

    $old_creds_direct = Get-Direct-Watson-BB-Credentials
    $old_creds_remote = Get-RemoteDesktop-Credentials

    Write-Output ('Current credentials:')
    Write-Output ('    Direct:')
    foreach($a_cred in $old_creds_direct)
    {
        Write-Output ($a_cred)
    }

    Write-Output ('    Remote:')
    foreach($a_cred in $old_creds_remote)
    {
        Write-Output ($a_cred)
    }

    # $old_creds = Get-Credentials-With-Wrong-Username
    # $old_creds = Get-Direct-Watson-BB-Credentials-With-Wrong-Type
    # $old_creds = Get-RemoteDesktop-Credentials-With-Wrong-Type

    # From the credentials with the wrong type, create those with the correct type (Generic).
    # Create-Generic-Credentials -old_creds $old_creds
    # Remove the old credentials with the wrong type
    # Remove-Old-Credentials -old_creds $old_creds

    
    # Create-Generic-Credentials 
    # Get-Termserv-Address-From-Network-Address
}


function Run-For-CSV-Hosts()
{

    $active_csv_path = "G:\Google Drive\Modern Behavior Box\Documentation\Computers Info\BB Computer Info Spreadsheet - Export.csv"
    # Loads from CSV
    $loaded_csv_info = Load-Remote-Computer-Info -csv_path $active_csv_path
    $active_csv_info = $loaded_csv_info

    # Enable Filtering for specify hosts:
#    $filtered_loaded_csv_info = $loaded_csv_info | Where Hostname -match WATSON-BB-1 | Where Hostname -notmatch WATSON-BB-10
     #$active_csv_info = $filtered_loaded_csv_info

     $active_csv_info

    # Get a string array of the target names
    $target_array = $active_csv_info.IP

    $final_hostnames = $active_csv_info.Hostname
   
    # Get Hostnames from IPs:
    $recovered_host_records = $target_array | ForEach-Object {Get-Reverse-Hostname-Lookup-From-IP -remote_desktop_address $_}
    $recovered_hostnames = $recovered_host_records.HostName
    # Get fully resolved network addresses from recovered host names:
    $final_network_addresses = $recovered_hostnames | ForEach-Object {Get-Address-From-Hostname -remote_desktop_hostname $_}
    $final_fully_resolved_hostnames = $recovered_hostnames

    $final_hostnames



    Update-Credentials -hostnames $final_hostnames
}



#Run-For-CSV-Hosts

Build-Ideal-Client-Credentials


