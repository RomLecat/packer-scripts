variable "cluster" {
    type = string
    default = "Main"
}

variable "dc" {
    type = string
    default = "Home"
}

variable "network" {
    type = string
    default = "SEC-PROVI"
}

variable "storage" {
    type = string
    default = "nas-ssd"
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

source "vsphere-iso" "debian" {
    CPUs = "2"
    RAM = "2048"
    RAM_reserve_all = true
    boot_command = [ 
        "<down>e<down><down><down><end>",
        "priority=critical auto=true preseed/url=https://oos.eu-west-2.outscale.com/homelab/packer_ks/debian11/preseed.cfg",
        "<leftCtrlOn>x<leftCtrlOff>"
    ]
    boot_wait = "5s"
    cluster = "${var.cluster}"
    convert_to_template = true
    datacenter = "${var.dc}"
    datastore = "${var.storage}"
    disk_controller_type = [ "pvscsi" ]
    firmware = "efi-secure"
    folder = "${var.template_dir}"
    guest_os_type = "debian11_64Guest"
    insecure_connection = "true"
    iso_checksum = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
    iso_urls = [ "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.3.0-amd64-netinst.iso" ]

    network_adapters {
        network = "${var.network}"
        network_card = "vmxnet3"
    }

    password = "${var.vcenter_password}"
    ssh_handshake_attempts = "150"
    ssh_password = "root"
    ssh_timeout = "25m"
    ssh_username = "root"

    storage {
        disk_size = "10000"
        disk_thin_provisioned = true
    }

    username = "${var.vcenter_user}"
    vcenter_server = "${var.vcenter_host}"
    vm_name = "Debian-11-${legacy_isotime("2006-01-02")}"
    vm_version = "19"
}

build {
    sources = [ "source.vsphere-iso.debian" ]
}
