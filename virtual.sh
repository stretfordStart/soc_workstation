#!/bin/bash

# Check if the script was called with the parameter -vm kali
if [ "$1" == "-vm" ] && [ "$2" == "kali" ]; then
    # Run the Vagrant commands to initialize and start the Kali Linux VM
    vagrant init kalilinux/rolling
    vagrant up
else
    # If the parameter is not provided or incorrect, display usage information
    echo "Usage: $0 -vm kali"
fi
