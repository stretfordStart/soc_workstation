#!/bin/bash

# Define variables
REMNUX_ISO_URL="https://app.box.com/s/8matvs5l0gc8vkr4xfq3szdm7mc9o0ad"
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

# Convert the OVA to a QCOW2 format
echo "Converting OVA to QCOW2..."
qemu-img convert -f ova -O qcow2 remnux.ova "$VM_NAME.qcow2"

# Create a QEMU VM with Virt-Manager
echo "Creating QEMU VM..."
virt-install \
    --name "$VM_NAME" \
    --memory "$VM_MEMORY" \
    --vcpus "$VM_CPU_CORES" \
    --disk path="$VM_NAME.qcow2" \
    --cdrom "$REMNUX_ISO_URL" \
    --boot hd,cdrom \
    --graphics spice \
    --network default \
    --os-variant ubuntu20.04 \
    --noautoconsole

# Clean up
echo "Cleaning up..."
rm remnux.ova

echo "REMnux VM setup complete. You can manage it with Virt-Manager."
