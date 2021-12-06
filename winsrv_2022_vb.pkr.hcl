# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "autounattend" {
    type    = string
    default = "./answer_files/2022/Autounattend.xml"
  }
  
  variable "disk_size" {
    type    = string
    default = "40000"
  }
  
  variable "disk_type_id" {
    type    = string
    default = "1"
  }
  
  variable "headless" {
    type    = string
    default = "false"
  }
  
  variable "iso_checksum" {
    type    = string
    default = "sha256:4f1457c4fe14ce48c9b2324924f33ca4f0470475e6da851b39ccbf98f44e7852"
  }
  
  variable "iso_url" {
    type    = string
    default = "/Users/shuyisong/Repo/iso/WinSrv2022_eva.iso"
  }
  
  variable "memory" {
    type    = string
    default = "2048"
  }
  
  variable "restart_timeout" {
    type    = string
    default = "5m"
  }
  
  variable "vhv_enable" {
    type    = string
    default = "false"
  }
  
  variable "virtio_win_iso" {
    type    = string
    default = "~/virtio-win.iso"
  }
  
  variable "vm_name" {
    type    = string
    default = "winsrv_2022"
  }
  
  variable "vmx_version" {
    type    = string
    default = "14"
  }
  
  variable "winrm_timeout" {
    type    = string
    default = "40m"
  }
  
  variable "boot_wait" {
    type  = string
    default = "6m"
  }
  
  # source blocks are generated from your builders; a source can be referenced in
  # build blocks. A build block runs provisioner and post-processors on a
  # source. Read the documentation for source blocks here:
  # https://www.packer.io/docs/templates/hcl_templates/blocks/source
  
  source "virtualbox-iso" "main" {
    #boot_command         = ""
    boot_wait            = "${var.boot_wait}"
    communicator         = "winrm"
    cpus                 = 2
    disk_size            = "${var.disk_size}"
    floppy_files         = [
      "${var.autounattend}",
      "./scripts/enable-winrm.ps1"
    ]
    guest_additions_mode = "disable"
    guest_os_type        = "Windows2016_64"
    headless             = "${var.headless}"
    iso_checksum         = "${var.iso_checksum}"
    iso_url              = "${var.iso_url}"
    memory               = "${var.memory}"
    shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
    vm_name              = "${var.vm_name}"
    winrm_password       = "vagrant"
    winrm_timeout        = "${var.winrm_timeout}"
    winrm_username       = "vagrant"
  }
  
  
  # a build block invokes sources and runs provisioning steps on them. The
  # documentation for build blocks can be found here:
  # https://www.packer.io/docs/templates/hcl_templates/blocks/build
  build {
    sources = [
      "source.virtualbox-iso.main"
    ]
  
    provisioner "windows-shell" {
      execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
      remote_path     = "/tmp/script.bat"
      scripts         = [
        "./scripts/enable-rdp.bat",
        "./scripts/set-winrm-automatic.bat"
        ]
    }
  
    provisioner "windows-restart" {
      restart_timeout = "${var.restart_timeout}"
    }

  
    post-processor "vagrant" {
      keep_input_artifact  = false
      output               = "winsvr_2022.box"
      vagrantfile_template = "vagrantfile-winsrv_2022.template"
    }
  }
  