#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y

if ! dpkg -l | grep -q gnome-core; then
    sudo apt-get install -y gnome-core
fi

if ! id "remnux" &>/dev/null; then
    sudo useradd -m -p "$(openssl passwd -1 malware)" -s /bin/bash remnux
fi

sudo -u remnux localectl set-x11-keymap ch
sudo timedatectl set-timezone Europe/Zurich

wget https://REMnux.org/remnux-cli || { echo "Failed to download REMnux CLI. Exiting."; exit 1; }
EXPECTED_HASH="88cd35b7807fc66ee8b51ee08d0d2518b2329c471b034ee3201e004c655be8d6"
ACTUAL_HASH=$(sha256sum remnux-cli | awk '{print $1}')

if [ "$EXPECTED_HASH" = "$ACTUAL_HASH" ]; then
    mv remnux-cli remnux
    chmod +x remnux
    sudo mv remnux /usr/local/bin
    # if not running in cloud mode the SSH deamon will be disabled and the SSH connection used by Vagrant gets terminated
    sudo remnux install --user=remnux --mode=cloud
else
    echo "Invalid REMnux CLI Hash. Exiting"
    exit 1
fi

file_path="/etc/inetsim/inetsim.conf"

# Use sed to replace lines in the file
sed -i 's/#start_service dns/start_service dns/g' "$file_path"
sed -i 's/#start_service irc/start_service irc/g' "$file_path"
sed -i 's/#service_bind_address/service_bind_address    0.0.0.0/g' "$file_path"
sed -i 's/#dns_default_ip/dns_default_ip    10.0.0.3/g' "$file_path"

# Install VSCode Extensions: Encode-Decode, Prettier, Email, Javascript Snippets
echo 'mitchdenny.ecdc,esbenp.prettier-vscode,leighlondon.eml,xabikos.javascriptsnippets' | Foreach-Object -Process {code --install-extension $_ --force}

# Get the MAC address of eth1
mac_address=$(ip link show eth1 | awk '/link/ {print $2}')

# Check if the MAC address is obtained successfully
if [ -z "$mac_address" ]; then
    echo "Error: Failed to retrieve MAC address for eth1."
    exit 1
fi

# Set the MAC address in /etc/udev/rules.d/10-network.rules
echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$mac_address\", NAME=\"eth1\"" | sudo tee /etc/udev/rules.d/10-network.rules > /dev/null

sudo udevadm control --reload-rules
