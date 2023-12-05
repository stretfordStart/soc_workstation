Set-ExecutionPolicy Unrestricted -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

# Disable the need for CTRL+ALT+DELETE on the Logonscreen
Write-Output "Disabling the need for CTRL+ALT+DELETE on the Logonscreen..."
try {
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DisableCAD" -Value 1 -ErrorAction Stop
  Write-Output "The need for CTRL+ALT+DELETE on the Logonscreen disabled."
}
catch {
  Write-Output "Failed to disable the need for CTRL+ALT+DELETE on the Logonscreen, Reason: $($_.Exception.Message)"
}

# Disable password complexity policy
Write-Output "Disabling password complexity policy..."
try {
  secedit /export /cfg $env:TEMP\secpol.cfg
  (gc $env:TEMP\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File $env:TEMP\secpol.cfg
  secedit /configure /db $env:windir\security\local.sdb /cfg $env:TEMP\secpol.cfg /areas SECURITYPOLICY
  rm -force $env:TEMP\secpol.cfg -confirm:$false
  Write-Output "Password complexity policy disabled."
}
catch {
  Write-Output "Failed to disable password complexity policy, Reason: $($_.Exception.Message)"
}

# Create user flare with password "malware", password should not expire
Write-Output "Creating user flare..."
try {
  $Password = ConvertTo-SecureString "malware" -AsPlainText -Force
  New-LocalUser -Name "flare" -Password $Password -PasswordNeverExpires $true
  Write-Output "User flare created."
}
catch {
  Write-Output "Failed to create user flare, Reason: $($_.Exception.Message)"
}

# Install windows terminal
Write-Output "Installing windows terminal..."
try {
  Invoke-WebRequest -Uri "https://aka.ms/terminal" -OutFile "$env:TEMP\WindowsTerminal.msixbundle"
  Add-AppxPackage -Path "$env:TEMP\WindowsTerminal.msixbundle"
  Write-Output "Windows terminal installed."
}
catch {
  Write-Output "Failed to install windows terminal, Reason: $($_.Exception.Message)"
}

# Turn off auto proxy settings
Write-Output "Turning off auto proxy settings..."
try {
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0
  Write-Output "Auto proxy settings turned off."
}
catch {
  Write-Output "Failed to turn off auto proxy settings, Reason: $($_.Exception.Message)"
}

# Install software using chocolatey
Write-Output "Installing software using chocolatey..."
$software = @("firefox", "7zip", "libreoffice-fresh", "thunderbird")
foreach ($sw in $software) {
  Write-Output "Installing $sw..."
  try {
    choco install $sw -y
    Write-Output "$sw installed."
  }
  catch {
    Write-Output "Failed to install $sw, Reason: $($_.Exception.Message)"
  }
}

# Set locale settings to German (Switzerland)
Write-Output "Setting locale settings to German (Switzerland)..."
try {
  Set-WinSystemLocale -SystemLocale de-CH
  Set-Culture -CultureInfo de-CH
  Write-Output "Locale settings set to de-CH."
}
catch {
  Write-Output "Failed to set locale settings, Reason: $($_.Exception.Message)"
}

# Set keyboard layout to Swiss (German)
Write-Output "Setting keyboard layout to Swiss (German)..."
try {
  Set-WinUserLanguageList -LanguageList de-CH -Force
  Write-Output "Keyboard layout set to de-CH."
}
catch {
  Write-Output "Failed to set keyboard layout, Reason: $($_.Exception.Message)"
}

# Stop and disable wuauserv service
Write-Output "Stopping and disabling wuauserv service..."
try {
  $wuauserv = Get-Service -Name "wuauserv" -ErrorAction Stop
  if ($null -ne $wuauserv) {
    Stop-Service -InputObject $wuauserv -Force -ErrorAction Stop
    Set-Service -InputObject $wuauserv -StartupType Disabled -ErrorAction Stop
  }
  Write-Output "wuauserv service stopped and disabled."
}
catch {
  Write-Output "Failed to stop and disable wuauserv service, Reason: $($_.Exception.Message)"
}

# Disable User Account Control (UAC)
Write-Output "Disabling User Account Control (UAC)..."
try {
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -ErrorAction Stop
  Write-Output "User Account Control (UAC) disabled."
}
catch {
  Write-Output "Failed to disable User Account Control (UAC), Reason: $($_.Exception.Message)"
}

# Disable Windows Defender features
Write-Output "Disabling Windows Defender features..."
try {
  Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
  Set-MpPreference -MAPSReporting 0 -ErrorAction Stop
  $defenderRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
  if (Test-Path $defenderRegistryPath) {
    New-ItemProperty -Path $defenderRegistryPath -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
  }
  Uninstall-WindowsFeature -Name Windows-Defender -ErrorAction Stop
  Write-Output "Windows Defender features disabled."
}
catch {
  Write-Output "Failed to disable Windows Defender features, Reason: $($_.Exception.Message)"
}

# Download and run flare script
Write-Output "Downloading and running flare script..."
try {
  $flareScriptUrl = 'https://raw.githubusercontent.com/mandiant/flare-vm/main/install.ps1'
  (New-Object Net.WebClient).DownloadFile($flareScriptUrl, 'install.ps1') -ErrorAction Stop
  Unblock-File -Path '.\install.ps1' -ErrorAction Stop
  Set-ExecutionPolicy Unrestricted -Force -ErrorAction Stop
  .\install.ps1 -ErrorAction Stop
  Write-Output "Flare script downloaded and run."
}
catch {
  Write-Output "Failed to download and run flare script, Reason: $($_.Exception.Message)"
}


# & '.\install.ps1' -password malware -noWait -noGui -config config.xml
