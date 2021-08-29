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

source "vsphere-iso" "ubuntu" {
    CPUs = "${var.cpu_cores}"
    RAM = "${var.ram_mb}"
    RAM_reserve_all = true
    boot_command = [ 
        "<esc><wait>", 
        "<esc><wait>", 
        "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;s=https://oos.eu-west-2.outscale.com/homelab/packer_ks/ubuntu2004/\"<enter><wait>", 
        "initrd /casper/initrd<enter><wait>", 
        "boot<enter>" 
    ]
    boot_order = "disk,cdrom"
    boot_wait = "5s"
    cluster = "${var.cluster}"
    convert_to_template = true
    datacenter = "${var.dc}"
    datastore = "${var.storage}"
    disk_controller_type = [ "pvscsi" ]
    firmware = "efi"
    folder = "${var.template_dir}"
    guest_os_type = "ubuntu64Guest"
    insecure_connection = "true"
    iso_checksum = "file:https://releases.ubuntu.com/focal/SHA256SUMS"
    iso_urls = [ "https://releases.ubuntu.com/focal/ubuntu-20.04.3-live-server-amd64.iso" ]

    network_adapters {
        network = "${var.network}"
        network_card = "vmxnet3"
    }

    password = "${var.vcenter_password}"
    ssh_handshake_attempts = "150"
    ssh_password = "${var.ssh_password}"
    ssh_timeout = "25m"
    ssh_username = "${var.ssh_user}"

    storage {
        disk_size = "10000"
        disk_thin_provisioned = true
    }

    username = "${var.vcenter_user}"
    vcenter_server = "${var.vcenter_host}"
    vm_name = "Ubuntu-20.04-${legacy_isotime("2006-01-02")}"
    vm_version = "15"
}

build {
    sources = [ "source.vsphere-iso.ubuntu" ]

    provisioner "shell" {
        execute_command = "echo 'root' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
        script = "scripts/prep_ubuntu.sh"
    }
}
