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
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
    gsettings set org.gnome.shell.extensions.user-theme name Flat-Remix-Blue-Darkest-fullPanel
    gsettings set org.gnome.desktop.interface gtk-theme Flat-Remix-GTK-Blue-Darkest-Solid
    gsettings set org.gnome.desktop.interface icon-theme Tela-circle
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

# Function to workaround Flameshot issue 
# https://github.com/flameshot-org/flameshot/issues/3272#issuecomment-1790111469
setup_flameshot() {
    local flameshot_script_path="/home/soc_user/flameshot.sh"
    local flameshot_script_content="#! /bin/sh
env XDG_SESSION_TYPE= QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui --delay 500"

    # Create the flameshot.sh script
    echo "$flameshot_script_content" > "$flameshot_script_path"
    chmod +x "$flameshot_script_path"

    # Remove the current shortcut binding for the "Printscreen" button
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot "''"

    # Add a custom key binding for the "Printscreen" button to run the Flameshot script
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Flameshot'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "$flameshot_script_path"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding 'Print'
}

# Main script
configure_gnome_settings
manage_backgrounds
setup_flameshot

firefox https://stretfordstart.github.io/soc_workstation_doc/
exit
