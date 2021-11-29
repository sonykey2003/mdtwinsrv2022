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

    config.vm.provider :virtualbox do |v, override|
        #v.gui = true
        v.customize ["modifyvm", :id, "--memory", 4096]
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["modifyvm", :id, "--vram", 128]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

    config.vm.provider :vmware_fusion do |v, override|
        v.gui = true
        v.vmx["memsize"] = "4096"
        v.vmx["numvcpus"] = "2"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsisas1068"
        v.vmx["gui.fitguestusingnativedisplayresolution"] = "TRUE"
        v.vmx["mks.enable3d"] = "TRUE"
        v.vmx["mks.forceDiscreteGPU"] = "TRUE"
        v.vmx["gui.fullscreenatpoweron"] = "TRUE"
        v.vmx["gui.viewmodeatpoweron"] = "fullscreen"
        v.vmx["gui.lastPoweredViewMode"] = "fullscreen"
        v.vmx["sound.startconnected"] = "FALSE"
        v.vmx["sound.present"] = "FALSE"
        v.vmx["sound.autodetect"] = "TRUE"
        v.enable_vmrun_ip_lookup = false
        v.whitelist_verified = true
        v.vmx["hgfs.linkRootShare"] = "FALSE"
    end

    config.vm.provider :vmware_workstation do |v, override|
        v.gui = true
        v.vmx["memsize"] = "4096"
        v.vmx["numvcpus"] = "2"
        v.vmx["ethernet0.virtualDev"] = "vmxnet3"
        v.vmx["RemoteDisplay.vnc.enabled"] = "false"
        v.vmx["RemoteDisplay.vnc.port"] = "5900"
        v.vmx["scsi0.virtualDev"] = "lsisas1068"
        v.enable_vmrun_ip_lookup = false
        v.whitelist_verified = true
        v.vmx["hgfs.linkRootShare"] = "FALSE"
    end

    config.vm.provider "hyperv" do |v|
        v.cpus = 2
        v.maxmemory = 4096
        v.linked_clone = true
    end
    
    config.vm.provider :libvirt do |libvirt, override|
        libvirt.memory = 4096
        libvirt.cpus = 2

        # Use WinRM for the default synced folder; or disable it if
        # WinRM is not available. Linux hosts don't support SMB,
        # and Windows guests don't support NFS/9P/rsync
        # See https://github.com/Cimpress-MCP/vagrant-winrm-syncedfolders
        if Vagrant.has_plugin?("vagrant-winrm-syncedfolders")
            override.vm.synced_folder ".", "/vagrant", type: "winrm"
        else
            override.vm.synced_folder ".", "/vagrant", disabled: true
        end

        # Enable Hyper-V enlightments, see
        # https://blog.wikichoon.com/2014/07/enabling-hyper-v-enlightenments-with-kvm.html
        libvirt.hyperv_feature :name => 'stimer',  :state => 'on'
        libvirt.hyperv_feature :name => 'relaxed', :state => 'on'
        libvirt.hyperv_feature :name => 'vapic',   :state => 'on'
        libvirt.hyperv_feature :name => 'synic',   :state => 'on'
    end
end
