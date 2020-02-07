New-StoredCredential -Target Contoso -Username User1 -Password Password
Get-Credential -Username User2 -Message “Please enter your password:” | New-StoredCredential -Target Contoso
$Cred = Get-StoredCredential -Target Contoso

Remove-StoredCredential -Target Contoso



$Cred = Get-StoredCredential -Target "TERMSRV/10.17.152.64"


Get-StoredCredential -Target "TERMSRV/10.17.152.156"

watsonlab

Get-StoredCredentials -Target "TERMSRV/10.17.152.156"