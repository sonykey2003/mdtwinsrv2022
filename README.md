# Automating Windows MDT End-to-end

> **_NOTE_**  
> This repo is inspired and initially forked from [StefanScherer's GitHub repository](https://github.com/jeffskinnerbox/Windows-10-Vagrant-Box), you can find more useful windows resources there. 

## Part 1: Build a vanila WinSrv 2022 Vagrant Box
### TL;DR
You can skip this part by using [my box](https://app.vagrantup.com/sonykey2003/boxes/winsrv2022) on Vagrant Cloud.

### System Requirements
* MacOS 12 Monterey or BigSur (Not tested on the lower versions).
* Virtualbox 6.1.30 (for Monterey at least).
* Packer 1.7.0 +
* Vagrant 2.2.17 +
* [MSFT RDP for Mac](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466?mt=12)


### Usage
* Download the ISO from your trusted source, in my case, I use the [eva image](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022) for testing purpose.
* Obtain the Checksum of the ISO via:
  * In Mac terminal
  ```sh
  shasum -a 256 <your-iso-path>
  ```
  * Replace the value in .pkr.hcl file
  ```hcl
   variable "iso_checksum" {
        type    = string
        default = "sha256:<your-iso-checksum>"
    }
  ```
* Run the line below to build the box (for virtualbox only)
```sh
packer build --var 'iso_url=<your-iso-path>' ./winsrv_2022_vb.pkr.hcl
```
* Once the box is created, covert a Vagrantfile from the Packer template.
```sh
cp ./mdtwinsrv2022/vagrantfile-winsrv_2022.template Vagrantfile
```

* Add the box to Vagrant
```sh
vagrant box add winsvr_2022.box
```

## Part 2: Auto-provision a ready-to-use MDT workbench from scratch

### Caveats
* Modify this line for your own folder mapping:
```ruby
config.vm.synced_folder "<iso-path>", "/mdt", type: "smb", smb_username: "<your_mac_username>"
```
  ***Note:*** the reason why I'm using SMB to map the host (MacOS) folder by knowing most of the folks hate it -- Unfortunately, it's the by far only technically viable way on Vagrant. [More Options](https://www.vagrantup.com/docs/synced-folders/basic_usage).
* Key in your Mac user's password when prompted:
 ```shell
 Win Svr 2022 Base Box: folders shortly. Please use the proper username/password of your
    Win Svr 2022 Base Box: account.
    Win Svr 2022 Base Box:  
    Win Svr 2022 Base Box: Username (<your_mac_username>): 
    Win Svr 2022 Base Box: Password (will be hidden): 
```
* Observe and validate the Vagrant provisioning script [prep-mdt.ps1](https://github.com/sonykey2003/mdtwinsrv2022/blob/master/scripts/prep-mdt.ps1) by:
  * Try the cmds from the list of available MDT cmdlets [here](https://techdirectarchive.com/2021/02/05/how-to-install-mdt-powershell-module/).
  * More MSFT [reference](https://docs.microsoft.com/en-us/mem/configmgr/mdt/samples-guide). 
* Customise your MDT settings via the [workbench](https://docs.microsoft.com/en-us/windows/deployment/deploy-windows-mdt/get-started-with-the-microsoft-deployment-toolkit). 



* Fire it up and enjoy!
```sh
Vagrant up && Vagrant rdp
```

##  Part 3: Auto-produce a customised Win10/11 ISO
### [Updates - 28 Jan 2022] 
In this new update, you will be able to produce an MDT customised ISO from scratch - Automatically! Just do a "Vagrant up", grab a coffee, sit-back and relax. 

### Prerequisite
* Create a folder to host the ISOs on Mac and:
  * [ts.xml](https://systemscenter.ru/mdt2012.en/tsxml.htm) - your own Task Sequence template.
  * [CustomSettings.ini & Bootstrap.ini](https://win10.guru/windows-deployment-with-mdt-part-3-customize-deployment/) - Customised task sequence settings. 

* Fill the "iso" path and your Mac login user name in Vagrantfile in line:
```
config.vm.synced_folder "<iso-path>", "/mdt", type: "smb", mb_username: "<your_mac_username>"
```
* Fire it up!
```
Vagrant up 
```
* Make sure "out_Win10_eva.iso" had landed, give it a go with Virtualbox or the real box. 