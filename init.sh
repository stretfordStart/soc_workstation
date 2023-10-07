#!/bin/bash

gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface clock-show-weekday true 
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'ch')]"
gsettings set org.gnome.desktop.screensaver user-switch-enabled false
gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Backgrounds
cp ~/soc_workstation/arch.png ~/Pictures/arch.png
gsettings set org.gnome.desktop.background picture-uri 'file:///home/soc_user/Pictures/arch.png'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///home/soc_user/Pictures/arch.png'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///home/soc_user/Pictures/arch.png'
cp ~/Pictures/arch.png ~/.config/background 

# GTK Theme:
cd ~/Downloads
git clone https://aur.archlinux.org/flat-remix-gtk.git
cd flat-remix-gtk
makepkg -si --noconfirm
gsettings set org.gnome.desktop.interface gtk-theme Flat-Remix-GTK-Blue-Darkest-Solid

# Icon Theme:
cd ~/Downloads
wget https://github.com/vinceliuice/Tela-circle-icon-theme/archive/refs/tags/2023-06-25.zip
unzip 2023-06-25.zip
wait
cd Tela-circle-icon-theme-2023-06-25/
sh install.sh
wait
gsettings set org.gnome.desktop.interface icon-theme Tela-circle

# Set user Theme:
cd ~/Downloads
git clone https://aur.archlinux.org/flat-remix-gnome.git
cd flat-remix-gnome
makepkg -si --noconfirm
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.shell.extensions.user-theme name Flat-Remix-Blue-Darkest-fullPanel

# Dash to Dock
cd ~/soc_workstation
gnome-extensions install dash.zip
# evtl. noch shell reload nötig
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode FOCUS_APPLICATION_WINDOWS
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-notifications-counter false

echo "Customization completed. Reboot your system for the changes to take effect."
