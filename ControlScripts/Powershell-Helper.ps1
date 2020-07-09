Set-PSRepository -Name PSGallery
Install-Module -Name PSSoftware
Install-Module -Name xStorage

Install-Module -Name OpenSSHUtils

# Network:
Install-Module -Name WinSCP
Install-Module -Name RobocopyPS
Install-Module -Name WorkflowManagerDSC
Install-Module -Name TaskRunner
Install-Module -Name PSDeploy
Install-Module -Name Start-parallel
Install-Module -Name Invoke-CommandAs # Invoke Command as System/User on Local/Remote computer using ScheduleTask.
Install-Module PSFramework

# Config:
Install-Module -Name ReverseDSC
Install-Module -Name SecurityPolicyDsc
Install-Module -Name AuditPolicyDsc
Install-Module -Name localaccount
Install-Module -Name WallpaperManager
Install-Module -Name xDefender
Install-Module -Name xSmbShare
Install-Module -Name ComputerManagementDsc
Install-Module -Name xComputerManagement
Install-Module -Name PolicyFileEditor
Install-Module -Name NetworkingDsc -AllowPrerelease
Install-Module -Name Carbon
Install-Module -Name Configuration

Install-Module -Name PsHosts # Manipulates the local hosts file

# Program Install/Uninstall Management:
Install-Module -Name ProgramManagement


# Helper
Install-Module -Name ImportExcel
Install-Module -Name SMLets
Install-Module -Name PsIni
Install-Module -Name MSI -AllowPrerelease
Install-Module -Name BurntToast
Install-Module -Name 7Zip4Powershell
Install-Module -Name PSWriteHTML
Install-Module -Name Plaster # Plaster scaffolds PowerShell projects and files.
Install-Module -Name PSFolderSize # gather folder size information, and output the results easily in various ways.

# Optional:

Install-Module -Name VSSetup
Install-Module -Name PSSharedGoods
Install-Module -Name PSWriteColor

# Reference:
Install-Module -Name PowerShellCookbook
Install-Module -Name ScriptBrowser

