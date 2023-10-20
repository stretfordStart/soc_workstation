Vagrant.configure("2") do |config|

  config.vm.network "private_network", type: "dhcp", virtualbox__intnet: "private_network_common"

  config.vm.define "Flare" do |flare|
    flare.vm.box = "stretfordStart/FlareVM"
    flare.vm.guest = :windows
    flare.vm.communicator = "winrm"
    flare.vm.network "private_network", type: "static", virtualbox__intnet: "private_network_flare", ip: "10.0.0.4"
    flare.vm.network "forwarded_port", guest: 3389, host: 3389, id: "rdp", auto_correct: true
    flare.vm.provider "virtualbox" do |vb|
      vb.memory = 8192
      vb.cpus = 2
    end
  end

  config.vm.define "REMnux" do |remnux|
    remnux.vm.box = "stretfordStart/REMnux"
    remnux.vm.network "private_network", type: "static", virtualbox__intnet: "private_network_remnux", ip: "10.0.0.3"
    remnux.vm.provider "virtualbox" do |vb|
      vb.memory = 8192
      vb.cpus = 2
    end
  end

end
