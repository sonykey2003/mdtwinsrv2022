# Build a Windows Server 2022 Vagrant box with Packer

> **_NOTE_**  
> It's a striped fork from [StefanScherer's GitHub repository](https://github.com/jeffskinnerbox/Windows-10-Vagrant-Box), you can find more useful windows resources there. 

## System Requirements
* MacOS 12 Monterey or BigSur (Not tested on other lower version)
* Virtualbox 6.1.30 (for Monterey at least) 
* Packer 1.7.0 +
* [MSFT RDP for Mac](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466?mt=12)


## Usage

* Run the line below to build the box (for virtualbox only)
```sh
packer build --var 'iso_url=<your-iso-path>' ./winsrv_2022_vb.pkr.hcl
```
* Once the box create, covert a Vagrantfile from the Packer template.
```sh
cp ./mdtwinsrv2022/vagrantfile-winsrv_2022.template Vagrantfile
```

* Add the box to Vagrant
```sh
agrant box add winsvr_2022.box
```
* Firing up and enjoy!
```sh
Vagrant up && Vagrant rdp
```
