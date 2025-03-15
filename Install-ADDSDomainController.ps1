# Windows PowerShell script for AD DS Additional Domain Controller Deployment

# Variáveis
$DomainName = "rodrigogreff.cloud"
$DatabasePath = "C:\Windows\NTDS"
$LogPath = "C:\Windows\NTDS"
$SysVolPath = "C:\Windows\SYSVOL"
$featureLogPath = "C:\poshlog\featurelog.txt"
$Password = (ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force)

# Instalar os recursos necessários: AD DS, DNS e GPMC
Start-Job -Name addFeature -ScriptBlock { 
    Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools 
    Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools 
    Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools 
} 
Wait-Job -Name addFeature 
Get-WindowsFeature | Where-Object { $_.Installed } >> $featureLogPath

# Promover o servidor como um Controlador de Domínio Adicional
Install-ADDSDomainController `
    -DomainName $DomainName `
    -InstallDns:$true `
    -Credential (Get-Credential) `
    -DatabasePath $DatabasePath `
    -LogPath $LogPath `
    -SysvolPath $SysVolPath `
    -NoGlobalCatalog:$false `
    -SafeModeAdministratorPassword $Password `
    -NoRebootOnCompletion:$false `
    -Force:$true

