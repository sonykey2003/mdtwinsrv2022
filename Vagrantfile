# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|
    config.vm.define "Win Svr 2022 Base Box"
    config.vm.box = "winsrv_2022"
    config.vm.communicator = "winrm"

    # Admin user name and password
    config.winrm.username = "vagrant"
    config.winrm.password = "vagrant"

    config.vm.guest = :windows
    config.windows.halt_timeout = 15

    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    config.vm.synced_folder "/Users/shuyisong/Repo/iso", "/iso", type: "smb", smb_username: "shuyisong"


    config.vm.provider :virtualbox do |v, override|
        #v.gui = true
        v.memory = 4096
        v.cpus = 2
        v.name = "winsrv2022_mdt"
        v.customize ["modifyvm", :id, "--vram", 128]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
end
