source "osc-bsu" "debian11" {
    force_deregister = true
    omi_name = "Debian-11-RLT-${ formatdate("YYYY.MM.DD", timestamp()) }"
    source_omi_filter {
        filters = {
            image-name = "Debian-11-2021.12.*"
        }
        owners = [ "Outscale" ]
    }
    ssh_interface = "public_ip"
    ssh_username = "outscale"
    vm_type = "tinav4.c2r2p3"
}

build {
    sources = [ "source.osc-bsu.debian11" ]

    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash -x '{{ .Path }}'"
        scripts = [ "./scripts/osc_debian11.sh" ]
        expect_disconnect = true
    }
}