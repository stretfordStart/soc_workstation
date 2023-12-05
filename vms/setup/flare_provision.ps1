Set-ExecutionPolicy Unrestricted -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

# Disable password complexity policy
secedit /export /cfg $env:TEMP\secpol.cfg
(gc $env:TEMP\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File $env:TEMP\secpol.cfg
secedit /configure /db $env:windir\security\local.sdb /cfg $env:TEMP\secpol.cfg /areas SECURITYPOLICY
rm -force $env:TEMP\secpol.cfg -confirm:$false

# Create user flare with password "malware", password should not expire
$Password = ConvertTo-SecureString "malware" -AsPlainText -Force
New-LocalUser -Name "flare" -Password $Password -PasswordNeverExpires $true

# Install windows terminal
Invoke-WebRequest -Uri "https://aka.ms/terminal" -OutFile "$env:TEMP\WindowsTerminal.msixbundle"
Add-AppxPackage -Path "$env:TEMP\WindowsTerminal.msixbundle"

# Turn off auto proxy settings
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0

# Install software using chocolatey
$software = @("firefox", "7zip", "libreoffice-fresh", "thunderbird")
foreach ($sw in $software) {
  choco install $sw -y
}

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

$flareScriptUrl = 'https://raw.githubusercontent.com/mandiant/flare-vm/main/install.ps1'
(New-Object Net.WebClient).DownloadFile($flareScriptUrl, 'install.ps1')
Unblock-File -Path '.\install.ps1'
Set-ExecutionPolicy Unrestricted -Force

& '.\install.ps1' -password malware -noWait -noGui -config config.xml
