
variable "cluster" {
    type = string
    default = "Main"
}

variable "cpu_cores" {
    type = string
    default = "1"
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
    default = "2048"
}

variable "ssh_password" {
    type = string
    default = "root"
}

variable "ssh_user" {
    type = string
    default = "root"
}

variable "storage" {
    type = string
    default = "SAN"
}

variable "template_dir" {
    type = string
    default = "templates"
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

source "vsphere-iso" "arch" {
    CPUs = "${var.cpu_cores}"
    RAM = "${var.ram_mb}"
    RAM_reserve_all = true
    boot_command = [
        "<enter><wait10><wait10><wait10><wait10><wait10>",
        "curl -O 'https://oos.eu-west-2.outscale.com/homelab/packer_ks/arch/install{,-chroot}.sh'<enter><wait>",
        "bash install.sh < install-chroot.sh && poweroff<enter>"
    ]
    boot_order = "disk,cdrom"
    cluster = "${var.cluster}"
    convert_to_template = true
    datacenter = "${var.dc}"
    datastore = "${var.storage}"
    firmware = "efi"
    folder = "${var.template_dir}"
    guest_os_type = "other4xLinux64Guest"
    insecure_connection = "true"
    communicator = "none"
    iso_checksum = "file:http://archlinux.mirrors.ovh.net/archlinux/iso/latest/sha1sums.txt"
    iso_urls = [ "http://archlinux.mirrors.ovh.net/archlinux/iso/latest/archlinux-${ formatdate("YYYY.MM", timestamp()) }.01-x86_64.iso" ]
    disable_shutdown = "true"

    network_adapters {
        network = "${var.network}"
        network_card = "vmxnet3"
    }

    password = "${var.vcenter_password}"
    ssh_password = "${var.ssh_password}"
    ssh_username = "${var.ssh_user}"

    storage {
        disk_size = "10000"
        disk_thin_provisioned = true
    }

    username = "${var.vcenter_user}"
    vcenter_server = "${var.vcenter_host}"
    vm_name = "ArchLinux-${legacy_isotime("2006-01-02")}"
    vm_version = "15"
}

build {
    sources = [ "source.vsphere-iso.arch" ]
}
