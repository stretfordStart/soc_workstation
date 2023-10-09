#!/bin/bash

# Function to configure GNOME settings
configure_gnome_settings() {
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.interface clock-show-weekday true 
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing
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

# Function to install and configure GTK theme
install_and_configure_gtk_theme() {
    cd "$HOME/Downloads"
    git clone https://aur.archlinux.org/flat-remix-gtk.git
    cd flat-remix-gtk
    makepkg -si --noconfirm
    gsettings set org.gnome.desktop.interface gtk-theme Flat-Remix-GTK-Blue-Darkest-Solid
}

# Function to install and configure icon theme
install_and_configure_icon_theme() {
    cd "$HOME/Downloads"
    wget https://github.com/vinceliuice/Tela-circle-icon-theme/archive/refs/tags/2023-06-25.zip
    unzip 2023-06-25.zip
    cd Tela-circle-icon-theme-2023-06-25/
    sh install.sh
    gsettings set org.gnome.desktop.interface icon-theme Tela-circle
}

# Function to install and configure user theme
install_and_configure_user_theme() {
    cd "$HOME/Downloads"
    git clone https://aur.archlinux.org/flat-remix-gnome.git
    cd flat-remix-gnome
    makepkg -si --noconfirm
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
    gsettings set org.gnome.shell.extensions.user-theme name Flat-Remix-Blue-Darkest-fullPanel
}

# Function to install and configure Dash to Dock extension
install_and_configure_dash_to_dock() {
    cd "$HOME/Downloads"
    wget https://github.com/micheleg/dash-to-dock/releases/download/extensions.gnome.org-v84/dash-to-dock@micxgx.gmail.com.zip
    gnome-extensions install dash-to-dock@micxgx.gmail.com.zip
    dbus-send --session --type=method_call --dest=org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.Logout uint32:1
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode FOCUS_APPLICATION_WINDOWS
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-notifications-counter false
}

install_grub_theme() {
    cd "$HOME/Downloads"
    git clone https://github.com/vinceliuice/grub2-themes.git
    sudo ./install.sh -b -t vimix -i white
}

# Main script
configure_gnome_settings
manage_backgrounds
install_and_configure_gtk_theme
install_and_configure_icon_theme
install_and_configure_user_theme
# install_and_configure_dash_to_dock
install_grub_theme

firefox https://stretfordstart.github.io/soc_workstation_doc/

echo "Customization completed. Reboot your system for the changes to take effect."
