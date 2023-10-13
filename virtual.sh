#!/bin/bash

# Define variables
REMNUX_ISO_URL="https://remnux.org/remnux-7.0-vm.ova"
VM_NAME="REMnux-VM"
VM_MEMORY="2048"  # Set the amount of RAM for the VM in MB
VM_CPU_CORES="2"  # Set the number of CPU cores for the VM
VM_DISK_SIZE="20G" # Set the VM disk size

# Download the REMnux ISO
echo "Downloading REMnux ISO..."
wget "$REMNUX_ISO_URL" -O remnux.ova

# Install required tools (if not already installed)
if ! command -v qemu-img &>/dev/null; then
    sudo apt-get install qemu-utils
fi

# Create a QEMU VM
echo "Creating QEMU VM..."
qemu-img create -f qcow2 "$VM_NAME.qcow2" "$VM_DISK_SIZE"

# Install the VM using the REMnux ISO
qemu-system-x86_64 \
    -name "$VM_NAME" \
    -m "$VM_MEMORY" \
    -smp "$VM_CPU_CORES" \
    -drive file="$VM_NAME.qcow2",format=qcow2 \
    -cdrom remnux.ova \
    -boot d \
    -vga std \
    -display gtk \
    -net user,hostfwd=tcp::2222-:22 -net nic

# Clean up
echo "Cleaning up..."
rm remnux.ova

echo "REMnux VM setup complete. You can connect via SSH to localhost:2222 (username: remnux, password: reverse)."
