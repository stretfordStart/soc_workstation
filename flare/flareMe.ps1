# FlareVM Creator


# Reads list of apps from file and removes them for all user accounts and from the OS image.
function RemoveApps {
    param(
        $appsFile,
        $message
    )

    Write-Output $message

    # Get list of apps from file at the path provided, and remove them one by one
    Foreach ($app in (Get-Content -Path $appsFile | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } )) 
    { 
        # Remove any spaces before and after the Appname
        $app = $app.Trim()

        # Remove any comments from the Appname
        if (-not ($app.IndexOf('#') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf('#'))
        }
        # Remove any remaining spaces from the Appname
        if (-not ($app.IndexOf(' ') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf(' '))
        }
        
        $appString = $app.Trim('*')
        Write-Output "Attempting to remove $appString..."

        # Remove installed app for all existing users
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

        # Remove provisioned app from OS image, so the app won't be installed for any new users
        Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
    }

    Write-Output ""
}


# Import & execute regfile
function RegImport {
    param 
    (
        $Message,
        $Path
    )

    Write-Output $Message
    reg import $path
    Write-Output ""
}

# Stop & Restart the windows explorer process
function RestartExplorer {
    Write-Output "> Restarting windows explorer to apply all changes."

    Start-Sleep 0.5

    taskkill /f /im explorer.exe

    Start-Process explorer.exe

    Write-Output ""
}


# Clear all pinned apps from the start menu. 
# Credit: https://lazyadmin.nl/win-11/customize-windows-11-start-menu-layout/
function ClearStartMenu {
    param(
        $message
    )

    Write-Output $message

    # Path to start menu template
    $startmenuTemplate = "$PSScriptRoot/Start/start2.bin"

    # Get all user profile folders
    $usersStartMenu = get-childitem -path "C:\Users\*\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

    # Copy Start menu to all users folders
    ForEach ($startmenu in $usersStartMenu) {
        $startmenuBinFile = $startmenu.Fullname + "\start2.bin"

        # Check if bin file exists
        if(Test-Path $startmenuBinFile) {
            Copy-Item -Path $startmenuTemplate -Destination $startmenu -Force

            $cpyMsg = "Replaced start menu for user " + $startmenu.Fullname.Split("\")[2]
            Write-Output $cpyMsg
        }
        else {
            # Bin file doesn't exist, indicating the user is not running the correct version of windows. Exit function
            Write-Output "Error: Start menu file not found. Please make sure you're running Windows 11 22H2 or later"
            return
        }
    }
    
    # Also apply start menu template to the default profile

    # Path to default profile
    $defaultProfile = "C:\Users\default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"

    # Create folder if it doesn't exist
    if(-not(Test-Path $defaultProfile)) {
        new-item $defaultProfile -ItemType Directory -Force | Out-Null
        Write-Output "Created LocalState folder for default user"
    }

    # Copy template to default profile
    Copy-Item -Path $startmenuTemplate -Destination $defaultProfile -Force
    Write-Output "Copied start menu template to default user folder"
}


# Check if Chocolatey is installed, and install it if not
if (!(Test-Path 'C:\ProgramData\chocolatey\chocolateyinstall\chocolatey.ps1')) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Write-Host "Chocolatey installed."
} else {
    Write-Host "Chocolatey is already installed."
}

# Check if the VirtualBox Guest Additions CD/DVD is attached
$drive = Get-WmiObject Win32_CDROMDrive | Where-Object { $_.Drive -like "*VBOX*" }

if ($drive) {
    # Navigate to the VirtualBox Guest Additions CD/DVD drive
    Set-Location -Path $drive.Drive

    # Run the VBoxWindowsAdditions executable with silent installation
    Start-Process -FilePath "VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait

    # Check the exit code to ensure successful installation
    if ($LASTEXITCODE -eq 0) {
        Write-Host "VirtualBox Guest Additions have been successfully installed."
        Write-Host "You may need to restart the virtual machine for the changes to take effect."
    } else {
        Write-Host "Failed to install VirtualBox Guest Additions."
    }
} else {
    Write-Host "VirtualBox Guest Additions CD/DVD is not attached to the virtual machine. Please attach it manually and rerun this script."
}

# Check if UAC is enabled and disable it
if ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA").EnableLUA -eq 1) {
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
    Write-Host "UAC has been disabled. You need to restart the system for changes to take effect."
}

# Check if Windows Updates are enabled and disable them if they are active
if ((Get-Service -Name "wuauserv").Status -eq "Running") {
    Set-Service -Name "wuauserv" -StartupType "Disabled"
    Stop-Service -Name "wuauserv"
    Write-Host "Windows Updates have been disabled. You need to restart the system for changes to take effect."
} else {
    Write-Host "Windows Updates are already disabled."
}

# Set network profile to Private if it's Public
if ((Get-NetConnectionProfile).NetworkCategory -eq "Public") {
    Set-NetConnectionProfile -NetworkCategory Private
}

# Enable PowerShell Remoting
Enable-PSRemoting -SkipNetworkProfileCheck -Force

# Disable Shutdown Tracker
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" -Name "ShutdownReasonOn" -Value 0

# Debloat
RemoveApps "$PSScriptRoot/Appslist.txt" "> Removing pre-installed windows apps..."
RemoveApps "$PSScriptRoot/GamingAppslist.txt" "> Removing gaming-related windows apps..."
ClearStartMenu "> Removing all pinned apps from the start menu..."
RegImport "> Disabling telemetry, diagnostic data, app-launch tracking and targeted ads..." $PSScriptRoot\Regfiles\Disable_Telemetry.reg
RegImport "> Disabling bing search, bing AI & cortana in windows search..." $PSScriptRoot\Regfiles\Disable_Bing_Cortana_In_Search.reg
RegImport "> Disabling tips & tricks on the lockscreen..." $PSScriptRoot\Regfiles\Disable_Lockscreen_Tips.reg
RegImport "> Disabling tips, tricks, suggestions and ads across Windows..." $PSScriptRoot\Regfiles\Disable_Windows_Suggestions.reg
RegImport "> Restoring the old Windows 10 style context menu..." $PSScriptRoot\Regfiles\Disable_Show_More_Options_Context_Menu.reg
RegImport "> Aligning taskbar buttons to the left..." $PSScriptRoot\Regfiles\Align_Taskbar_Left.reg
RegImport "> Hiding the search icon from the taskbar..." $PSScriptRoot\Regfiles\Hide_Search_Taskbar.reg
RegImport "> Changing taskbar search to icon only..." $PSScriptRoot\Regfiles\Show_Search_Icon.reg
RegImport "> Changing taskbar search to icon with label..." $PSScriptRoot\Regfiles\Show_Search_Icon_And_Label.reg
RegImport "> Changing taskbar search to search box..." $PSScriptRoot\Regfiles\Show_Search_Box.reg
RegImport "> Hiding the taskview button from the taskbar..." $PSScriptRoot\Regfiles\Hide_Taskview_Taskbar.reg
RegImport "> Disabling Windows copilot..." $PSScriptRoot\Regfiles\Disable_Copilot.reg
RegImport "> Disabling the widget service and hiding the widget icon from the taskbar..." $PSScriptRoot\Regfiles\Disable_Widgets_Taskbar.reg
RegImport "> Hiding the chat icon from the taskbar..." $PSScriptRoot\Regfiles\Disable_Chat_Taskbar.reg
RegImport "> Unhiding hidden files, folders and drives..." $PSScriptRoot\Regfiles\Show_Hidden_Folders.reg
RegImport "> Enabling file extensions for known file types..." $PSScriptRoot\Regfiles\Show_Extensions_For_Known_File_Types.reg
RegImport "> Hiding duplicate removable drive entries from the windows explorer navigation pane..." $PSScriptRoot\Regfiles\Hide_duplicate_removable_drives_from_navigation_pane_of_File_Explorer.reg
RegImport "> Hiding the onedrive folder from the windows explorer navigation pane..." $PSScriptRoot\Regfiles\Hide_Onedrive_Folder.reg
RegImport "> Hiding the 3D objects folder from the windows explorer navigation pane..." $PSScriptRoot\Regfiles\Hide_3D_Objects_Folder.reg
RegImport "> Hiding the music folder from the windows explorer navigation pane..." $PSScriptRoot\Regfiles\Hide_Music_folder.reg
RegImport "> Hiding 'Include in library' in the context menu..." $PSScriptRoot\Regfiles\Disable_Include_in_library_from_context_menu.reg
RegImport "> Hiding 'Give access to' in the context menu..." $PSScriptRoot\Regfiles\Disable_Give_access_to_context_menu.reg
RegImport "> Hiding 'Share' in the context menu..." $PSScriptRoot\Regfiles\Disable_Share_from_context_menu.reg

# Enable WinRM
winrm quickconfig -q
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
Set-Service -Name WinRM -StartupType "Automatic"

RestartExplorer

(New-Object net.webclient).DownloadFile('https://raw.githubusercontent.com/mandiant/flare-vm/main/install.ps1',"install.ps1")
Unblock-File .\install.ps1
Set-ExecutionPolicy Unrestricted -Force
Invoke-Expression -Command "install.ps1 -customConfig soc.xml -password malware -noWait -noGui"

Write-Output ""
Write-Output ""
Write-Output "Script completed successfully!"