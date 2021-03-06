﻿<#  
.SYNOPSIS
    Preps server for SCCM Distribution Point  
.DESCRIPTION  
    This script installs all necessary Roles and Features as well
    as firewall rules needed for SCCM DP Installation/Deployment.
.NOTES  
    File Name   : Prep-SCCM-DP.ps1  
    Author      : Jordan Colton - jordan.colton@imesd.k12.or.us  
    Requires    : PowerShell V2
    Version 1.1 : 3/14/2017 10:33
.LINK  
    https://github.com/Degrader/Prep-SCCM-DP
#>

#Get Domain name
$DomainName = (Get-WmiObject win32_computersystem).domain

#Get Computer name
$Computer = $env:COMPUTERNAME
 
#Local Administrator group name
$ADSI = [ADSI]("WinNT://$Computer")
$Group = $ADSI.Children.Find('Administrators', 'group')

#Add Local Computer account to Local Administrators
$Group.Add(("WinNT://$Computer`$,computer"))

###Role & Feature Configuration
[string[]]$InstallFeatures = @()

Write-Host "Gathering Role Information...`n`n`n`n`n`n`n" -BackgroundColor DarkBlue -ForegroundColor Yellow

if ((Get-WindowsFeature NET-Framework-Features).Installed -eq 0){
    $InstallFeatures += "NET-Framework-Features"
    Write-Host "IIS Management Console will be installed"
    }
if ((Get-WindowsFeature NET-Framework-45-Features).Installed -eq 0){
    $InstallFeatures += "NET-Framework-45-Features"
    Write-Host "IIS Management Console will be installed"
    }
if ((Get-WindowsFeature BITS).Installed -eq 0){
    $InstallFeatures += "BITS"
    Write-Host "BITS will be installed"
    }
if ((Get-WindowsFeature RDC).Installed -eq 0){
    $InstallFeatures += "RDC"
    Write-Host "Remote Differential Compression will be installed"
    }
if ((Get-WindowsFeature Web-Server).Installed -eq 0){
    $InstallFeatures += "Web-Server"
    Write-Host "Web Server IIS will be installed"
    }
if ((Get-WindowsFeature Web-Common-Http).Installed -eq 0){
    $InstallFeatures += "Web-Common-Http"
    Write-Host "Common HTTP Features (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-Default-Doc).Installed -eq 0){
    $InstallFeatures += "Web-Default-Doc"
    Write-Host "Default Doc (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-Static-Content).Installed -eq 0){
    $InstallFeatures += "Web-Static-Content"
    Write-Host "Web Static Content (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-App-Dev).Installed -eq 0){
    $InstallFeatures += "Web-App-Dev"
    Write-Host "Application Development (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-Asp-Net).Installed -eq 0){
    $InstallFeatures += "Web-Asp-Net"
    Write-Host "ASP.NET 3.5 (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-Asp-Net45).Installed -eq 0){
    $InstallFeatures += "Web-Asp-Net45"
    Write-Host "ASP.NET 4.5 (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-App-Ext45).Installed -eq 0){
    $InstallFeatures += "Web-App-Ext45"
    Write-Host ".NET Extensibility 3.5 (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-ISAPI-Ext).Installed -eq 0){
    $InstallFeatures += "Web-ISAPI-Ext"
    Write-Host "ISAPI Extensions (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-Security).Installed -eq 0){
    $InstallFeatures += "Web-Security"
    Write-Host "Security (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-Windows-Auth).Installed -eq 0){
    $InstallFeatures += "Web-Windows-Auth"
    Write-Host "Windows Authentication (IIS) will be installed"
    }
if ((Get-WindowsFeature Web-Mgmt-Tools).Installed -eq 0){
    $InstallFeatures += "Web-Mgmt-Tools"
    Write-Host "IIS Management Tools will be installed"
    }
if ((Get-WindowsFeature Web-Mgmt-Console).Installed -eq 0){
    $InstallFeatures += "Web-Mgmt-Console"
    Write-Host "IIS Management Console will be installed"
    }
if ((Get-WindowsFeature Web-Mgmt-Compat).Installed -eq 0){
    $InstallFeatures += "Web-Mgmt-Compat"
    Write-Host "IIS 6 Management Compatibility will be installed"
    }
if ((Get-WindowsFeature Web-Metabase).Installed -eq 0){
    $InstallFeatures += "Web-Metabase"
    Write-Host "IIS 6 Metabase Compatibility will be installed"
    }
if ((Get-WindowsFeature Web-WMI).Installed -eq 0){
    $InstallFeatures += "Web-WMI"
    Write-Host "IIS 6 WMI Compatibility will be installed"
    }
if ((Get-WindowsFeature Web-Scripting-Tools).Installed -eq 0){
    $InstallFeatures += "Web-Scripting-Tools"
    Write-Host "IIS Management Scripts and Tools will be installed"
    }

Write-Host "`nInstalling configured Roles & Features..."  -BackgroundColor DarkBlue -ForegroundColor Yellow

if ($InstallFeatures -ne $null){
    Add-WindowsFeature $InstallFeatures
    Write-Host "`nFeature Installation complete." -ForegroundColor Green
}

if ($InstallFeatures -eq $null){Write-Host "`nNo Roles needed to be installed." -ForegroundColor Green}

###Firewall Rules
Write-host "Setting up Firewall rules for CM Distribution Point." -BackgroundColor DarkBlue -ForegroundColor Yellow

Write-Host "Allowing File and Print Sharing SMB In, TCP" -BackgroundColor DarkBlue -ForegroundColor Yellow
Set-NetFirewallRule -Name "FPS-SMB-In-TCP" -Profile Domain,Private -Protocol TCP -Action Allow -Enabled True

Write-Host "Allowing RPC Endpoint Mapper, TCP" -BackgroundColor DarkBlue -ForegroundColor Yellow
try {New-NetFirewallRule -Name "RPC Endpoint Mapper TCP" -DisplayName "RPC Endpoint Mapper TCP" -Protocol TCP -Direction Inbound -LocalPort "RPCEPMap" -Program "%SystemRoot%\System32\svchost.exe" -Profile Domain,Private -Action Allow -Enabled True -ErrorAction Stop}
catch [Microsoft.Management.Infrastructure.CimException] {write-host "Rule Already Exists"}

Write-Host "Allowing RPC Endpoint Mapper via Port 135, TCP" -BackgroundColor DarkBlue -ForegroundColor Yellow
try {New-NetFirewallRule -Name "RPC Endpoint Mapper (135) TCP" -DisplayName "RPC Endpoint Mapper (135) TCP" -Protocol TCP -Direction Inbound -LocalPort "135" -Program "%SystemRoot%\System32\svchost.exe" -Profile Domain,Private -Action Allow -Enabled True -ErrorAction Stop}
catch [Microsoft.Management.Infrastructure.CimException] {write-host "Rule Already Exists"}

Write-Host "Allowing RPC Endpoint Mapper via Port 135, UDP" -BackgroundColor DarkBlue -ForegroundColor Yellow
try {New-NetFirewallRule -Name "RPC Endpoint Mapper (135) UDP" -DisplayName "RPC Endpoint Mapper (135) UDP" -Protocol UDP -Direction Inbound -LocalPort "135" -Program "%SystemRoot%\System32\svchost.exe" -Profile Domain,Private -Action Allow -Enabled True -ErrorAction Stop}
catch [Microsoft.Management.Infrastructure.CimException] {write-host "Rule Already Exists"}

Write-Host "Allowing WMI RPCSS, TCP" -BackgroundColor DarkBlue -ForegroundColor Yellow
Set-NetFirewallRule -Name "WMI-RPCSS-In-TCP" -Profile Domain,Private -Protocol TCP -Action Allow -Enabled True


Write-Host "`nFirewall Rules set`n" -ForegroundColor Green

Write-Host "System Restart is required..." -BackgroundColor DarkRed -ForegroundColor White

###Reboot
Restart-Computer -Force