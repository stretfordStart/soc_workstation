#!/bin/bash

# Set Swiss locales and Zurich timezone
echo 'de_CH ISO-8859-1' > /etc/locale.gen
locale-gen
echo 'LANG=de_CH.ISO-8859-1' > /etc/locale.conf
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

# Add Firefox and Terminal to the dock
su -c "cp /usr/share/applications/firefox.desktop /etc/skel/Desktop/"
su -c "cp /usr/share/applications/org.gnome.Terminal.desktop /etc/skel/Desktop/"

# Remove GNOME Web, GNOME Music, and GNOME Software from the dock
su -c "rm /etc/skel/Desktop/org.gnome.Epiphany.desktop"
su -c "rm /etc/skel/Desktop/org.gnome.Music.desktop"
su -c "rm /etc/skel/Desktop/org.gnome.Software.desktop"

# Disable energy-saving settings and sleep/suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'nothing'

# Install necessary packages
pacman -S firefox gnome-terminal qemu virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode ebtables libguestfs

# Enable libvirtd service
systemctl enable libvirtd.service

# Configure libvirtd.conf
sed -i 's/^#unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sed -i 's/^#unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

# Add user to the libvirt group
usermod -a -G libvirt soc_user

# Restart libvirtd.service
systemctl restart libvirtd.service

# Load KVM module with nested virtualization support
modprobe -r kvm_intel
echo "options kvm-intel nested=1" | tee /etc/modprobe.d/kvm-intel.conf
modprobe kvm_intel nested=1



echo "Customization completed. Reboot your system for the changes to take effect."
