# Description

This folder contains the Vagrantfile and scripts to automatically set up the analysis VMs.
To create both VMs run `vagrant up`.

If you only want one VM you can specify it like that: `vagrant up REMnux` or `vagrant up FlareVM`.

To create a box use the Bash script from the "tools" folder of this repository: [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt).
`sudo sh create_box.sh /var/lib/libvirt/images/VM_FILE_NAME.IMG`
