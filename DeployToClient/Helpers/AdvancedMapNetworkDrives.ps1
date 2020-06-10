# This script should successfully mount all network drives required in a way better than "MapNetworkDrives.cmd".
# TODO: Need to make a .cmd launcher for it.

# From https://stackoverflow.com/questions/51640983/powershell-map-network-drive-if-does-not-exists
function Get-Workstation-Transfer-Credential()
{
    $User = "RDE20007\watsonlabBB"
    $PWord = ConvertTo-SecureString -String "c474115B357" -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
    return $Credential
}

function Get-Overseer-Transfer-Credential()
{
    $User = "WATSON-BB-OVERSEER\watsonlab"
    $PWord = ConvertTo-SecureString -String "cajal1852" -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
    return $Credential
}


function MapWorkstationNetworkDrive()
{
    $Name = "S"
    $Path = "\\RDE20007.umhs.med.umich.edu\BehavioralBoxServerShare"

    $MappedDrive = (Get-PSDrive -Name $Name -ErrorAction SilentlyContinue)
    $Credential = Get-Workstation-Transfer-Credential

    #Check if drive is already mapped
    if($MappedDrive)
    {
      #Drive is mapped. Check to see if it mapped to the correct path
      if($MappedDrive.DisplayRoot -ne $Path)
      {
        # Drive Mapped to the incorrect path. Remove and readd:
        Remove-PSDrive -Name $Name
        New-PSDrive -Name $Name -Root $Path -Persist -PSProvider "FileSystem" -Scope Global -Credential $Credential
      }
    }
    else
    {
      #Drive is not mapped
      New-PSDrive -Name $Name -Root $Path -Persist -PSProvider "FileSystem" -Scope Global -Credential $Credential
    }
}

function MapOverseerNetworkDrive_I()
{
    $Name = "I"
    $Path = "\\WATSON-BB-OVERSEER\ServerInternal-00"

    $MappedDrive = (Get-PSDrive -Name $Name -ErrorAction SilentlyContinue)
    $Credential = Get-Overseer-Transfer-Credential

    #Check if drive is already mapped
    if($MappedDrive)
    {
      #Drive is mapped. Check to see if it mapped to the correct path
      if($MappedDrive.DisplayRoot -ne $Path)
      {
        # Drive Mapped to the incorrect path. Remove and readd:
        Remove-PSDrive -Name $Name
        New-PSDrive -Name $Name -Root $Path -PSProvider "FileSystem" -Scope Global -Credential $Credential -Persist 
      }
    }
    else
    {
      #Drive is not mapped
      #New-PSDrive -Name $Name -Root $Path -PSProvider "FileSystem" -Scope Global -Credential $Credential -Persist 
      New-PSDrive -Name "I" -Root "\\WATSON-BB-OVERSEER\ServerInternal-00" -PSProvider "FileSystem" -Credential $Credential -Persist     
    }
}


function MapOverseerNetworkDrive_O()
{
    $Name = "O"
    $Path = "\\WATSON-BB-OVERSEER\ServerInternal-01"

    $MappedDrive = (Get-PSDrive -Name $Name -ErrorAction SilentlyContinue)
    $Credential = Get-Overseer-Transfer-Credential

    #Check if drive is already mapped
    if($MappedDrive)
    {
      #Drive is mapped. Check to see if it mapped to the correct path
      if($MappedDrive.DisplayRoot -ne $Path)
      {
        # Drive Mapped to the incorrect path. Remove and readd:
        Remove-PSDrive -Name $Name
        New-PSDrive -Name $Name -Root $Path -Scope Global -Persist -PSProvider "FileSystem" -Credential $Credential
      }
    }
    else
    {
      #Drive is not mapped
      New-PSDrive -Name $Name -Root $Path -Scope Global -Persist -PSProvider "FileSystem" -Credential $Credential
    }
}

function MapOverseerNetworkDrives()
{
    MapOverseerNetworkDrive_I
    MapOverseerNetworkDrive_O
}

function MapAllNetworkDrives()
{
    MapWorkstationNetworkDrive
    MapOverseerNetworkDrives
}

MapAllNetworkDrives



