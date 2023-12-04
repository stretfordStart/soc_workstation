#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y

if ! dpkg -l | grep -q gnome-core; then
    sudo apt-get install -y gnome-core
fi

if ! id "remnux" &>/dev/null; then
    sudo useradd -m -p "$(openssl passwd -1 malware)" -s /bin/bash remnux
fi

if ! dpkg -l | grep -q qemu-guest-agent; then
    sudo apt-get install -y qemu-guest-agent
    sudo systemctl enable qemu-guest-agent
    sudo systemctl start qemu-guest-agent
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

# Install VSCode Extensions: Encode-Decode, Prettier, Email, Javascript Snippets
echo 'mitchdenny.ecdc,esbenp.prettier-vscode,leighlondon.eml,xabikos.javascriptsnippets' | Foreach-Object -Process {code --install-extension $_ --force}

