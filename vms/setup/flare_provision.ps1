# Set execution policy for the current process and update security protocol
Set-ExecutionPolicy Unrestricted -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

# Install Chocolatey
Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Stop Windows Update service and disable it on startup
$wuauserv = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue
if ($null -ne $wuauserv) {
    Stop-Service -InputObject $wuauserv -Force
    Set-Service -InputObject $wuauserv -StartupType Disabled
}

# Disable User Account Control (UAC)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# Disable Windows Defender features
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -MAPSReporting 0
$defenderRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if (Test-Path $defenderRegistryPath) {
    New-ItemProperty -Path $defenderRegistryPath -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
}
Uninstall-WindowsFeature -Name Windows-Defender

# Download and execute FlareVM Script
$flareScriptUrl = 'https://raw.githubusercontent.com/mandiant/flare-vm/main/install.ps1'
(New-Object Net.WebClient).DownloadFile($flareScriptUrl, 'install.ps1')
Unblock-File -Path '.\install.ps1'
Set-ExecutionPolicy Unrestricted -Force

# Execute FlareVM Script
& '.\install.ps1' -password malware -noWait -noGui -config config.xml
