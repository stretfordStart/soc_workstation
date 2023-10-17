#!/bin/bash

# Function to configure GNOME settings
configure_gnome_settings() {
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.interface clock-show-weekday true 
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'ch')]"
    gsettings set org.gnome.desktop.screensaver user-switch-enabled false
    gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    dconf write /org/gnome/shell/favorite-apps "['firefox.desktop', 'virt-manager.desktop', 'org.gnome.Nautilus.desktop', 'com.gexperts.Tilix.desktop']"
}

# Function to manage backgrounds
manage_backgrounds() {
    picture_path="$HOME/Pictures/arch.png"
    cp "$HOME/soc_workstation/arch.png" "$picture_path"
    gsettings set org.gnome.desktop.background picture-uri "file://$picture_path"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$picture_path"
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$picture_path"
    cp "$picture_path" "$HOME/.config/background"
}

# Function to install and configure Dash to Dock extension
install_and_configure_dash_to_dock() {
    cd "$HOME/Downloads"
    wget https://github.com/micheleg/dash-to-dock/releases/download/extensions.gnome.org-v84/dash-to-dock@micxgx.gmail.com.zip
    gnome-extensions install dash-to-dock@micxgx.gmail.com.zip
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode FOCUS_APPLICATION_WINDOWS
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-notifications-counter false
}

# Main script
configure_gnome_settings
manage_backgrounds
gsettings set org.gnome.desktop.interface gtk-theme Flat-Remix-GTK-Blue-Darkest-Solid
gsettings set org.gnome.desktop.interface icon-theme Tela-circle
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.shell.extensions.user-theme name Flat-Remix-Blue-Darkest-fullPanel
# install_and_configure_dash_to_dock

firefox https://stretfordstart.github.io/soc_workstation_doc/
exit
