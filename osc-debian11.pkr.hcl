packer {
    required_plugins {
        outscale = {
            source  = "github.com/outscale/outscale"
            version = ">= 1.0.3"
        }
    }
}

source "outscale-bsu" "debian11" {
    force_deregister = true
    omi_name = "Debian-11-RLT-${ formatdate("YYYY.MM.DD", timestamp()) }"
    source_omi_filter {
        filters = {
            image-name = "Debian-11-*"
        }
        owners = [ "Outscale" ]
        most_recent = "true"
    }
    ssh_interface = "public_ip"
    ssh_username = "outscale"
    vm_type = "tinav5.c2r2p2"
}

build {
    sources = [ "source.outscale-bsu.debian11" ]

    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash -x '{{ .Path }}'"
        scripts = [ "./scripts/osc_debian11.sh" ]
        expect_disconnect = true
    }
}
