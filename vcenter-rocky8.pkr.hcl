
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

source "vsphere-iso" "rocky" {
    CPUs = "${var.cpu_cores}"
    RAM = "${var.ram_mb}"
    RAM_reserve_all = true
    boot_command = [ "<up><wait>e<wait><down><wait><down><wait><end> initrd=initrd.img inst.text inst.gpt inst.ks=https://oos.eu-west-2.outscale.com/homelab/packer_ks/rocky8.cfg <leftCtrlOn>x<leftCtrlOff>" ]
    boot_order = "disk,cdrom"
    cluster = "${var.cluster}"
    convert_to_template = true
    datacenter = "${var.dc}"
    datastore = "${var.storage}"
    disk_controller_type = "pvscsi"
    firmware = "efi"
    folder = "${var.template_dir}"
    guest_os_type = "centos8_64Guest"
    insecure_connection = "true"
    iso_checksum = "file:https://download.rockylinux.org/pub/rocky/8/isos/x86_64/CHECKSUM"
    iso_urls = [ "https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.4-x86_64-boot.iso" ]

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
    vm_name = "RockyLinux-8-${legacy_isotime("2006-01-02")}"
    vm_version = "15"
}

build {
    sources = [ "source.vsphere-iso.rocky" ]

    provisioner "shell" {
        execute_command = "echo 'root' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
        script = "scripts/prep_rocky8.sh"
    }
}
