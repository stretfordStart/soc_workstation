Set-ExecutionPolicy Unrestricted -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

# Disable the need for CTRL+ALT+DELETE on the Logonscreen
Write-Output "Disabling the need for CTRL+ALT+DELETE on the Logonscreen..."
try {
  Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'DisableCAD' -Value 1
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
  $Username = "flare"
  $Password = ConvertTo-SecureString "malware" -AsPlainText -Force
  New-LocalUser -Name "flare" -Password $Password -PasswordNeverExpires:$true
  Add-LocalGroupMember -Group "Users" -Member $Username
  Add-LocalGroupMember -Group "Administrators" -Member $Username
  Write-Output "User flare created."
}
catch {
  Write-Output "Failed to create user flare, Reason: $($_.Exception.Message)"
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
$software = @("firefox", "7zip", "libreoffice-fresh", "thunderbird", "microsoft-windows-terminal")
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

# Download and run flare script
Write-Output "Downloading and running flare script..."
try {
  $flareScriptUrl = 'https://raw.githubusercontent.com/mandiant/flare-vm/main/install.ps1'
  (New-Object Net.WebClient).DownloadFile($flareScriptUrl, 'install.ps1') -ErrorAction Stop
  Unblock-File -Path '.\install.ps1'
  Set-ExecutionPolicy Unrestricted -Force -ErrorAction Stop
  Write-Output "Flare script downloaded."
}
catch {
  Write-Output "Failed to download and run flare script, Reason: $($_.Exception.Message)"
}

& '.\install.ps1' -password malware -noWait -noGui -noChecks -config https://raw.githubusercontent.com/HuskyHacks/PMAT-labs/main/
