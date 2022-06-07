variable "cluster" {
    type = string
    default = "Main"
}

variable "cpu_cores" {
    type = string
    default = "2"
}

variable "dc" {
    type = string
    default = "Home"
}

variable "network" {
    type = string
    default = "SEC-PROVI"
}

variable "ram_mb" {
    type = string
    default = "4096"
}

variable "storage" {
    type = string
    default = "nas-nvme"
}

variable "template_dir" {
    type = string
    default = "templates"
}

variable "host_type" {
    type = string
    default = "efi-secure"
}

variable "tpm" {
    type = bool
    default = true
}

variable "vcenter_host" {
    type = string
    default = "${env("VCENTER_HOST")}"
}

variable "vcenter_password" {
    type = string
    default = "${env("VCENTER_PASSWORD")}"
}

variable "vcenter_user" {
    type = string
    default = "${env("VCENTER_USER")}"
}

variable "windows_version" {
    type = string
    default = "11"
}

variable "windows_iso" {
	type = string
	default = "https://oos.eu-west-2.outscale.com/homelab/iso/Win11_English_x64v1.iso"
}

packer {
    required_plugins {
        windows-update = {
            source = "github.com/rgl/windows-update"
            version = ">= 0.13.0"
        }
        vsphere = {
            source  = "github.com/hashicorp/vsphere"
            version = ">= 1.0.3"
        }
    }
}

source "vsphere-iso" "windows" {
    CPUs = "${var.cpu_cores}"
    RAM = "${var.ram_mb}"
    RAM_reserve_all = true
    boot_command = [ "<enter>" ]
    boot_wait = "2s"
    cluster = "${var.cluster}"
    communicator = "winrm"
    convert_to_template = true
    datacenter = "${var.dc}"
    datastore = "${var.storage}"
    disk_controller_type = [ "lsilogic-sas" ]
    firmware = "${var.host_type}"
    floppy_files = [ 
        "kickstart/windows${var.windows_version}/autounattend.xml",
        "scripts/windows/vmtools.cmd",
        "scripts/windows/setup.ps1"
    ]
    folder = "${var.template_dir}"
    guest_os_type = "windows9_64Guest"
    insecure_connection = true
    iso_checksum = "none"
    iso_paths = [ "[] /vmimages/tools-isoimages/windows.iso" ]
    iso_urls = [ "${var.windows_iso}" ]
    network_adapters {
        network = "${var.network}"
        network_card = "vmxnet3"
    }
    password = "${var.vcenter_password}"
    storage {
        disk_size = "40000"
        disk_thin_provisioned = true
    }
    username = "${var.vcenter_user}"
    vcenter_server = "${var.vcenter_host}"
    vm_name = "Windows-${var.windows_version}-${legacy_isotime("2006-01-02")}"
    vm_version = "15"
    vTPM = var.tpm
    winrm_username = "Administrator"
    winrm_password = "Password!"
    winrm_timeout = "1h30m"
    winrm_use_ssl = true
    winrm_insecure = true
    winrm_use_ntlm = true
}

build {
    sources = [ "source.vsphere-iso.windows" ]

    provisioner "windows-update" { }

    provisioner "powershell" {
        scripts = [
            "scripts/windows/enable-rdp.ps1"
        ]
    }
}
