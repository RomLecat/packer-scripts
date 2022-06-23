#!/bin/bash

# Set apt preferences
cat <<EOF > /etc/apt/preferences.d/90_default
Package: *
Pin: release a=stable
Pin-Priority: 990

Package: *
Pin: release a=stable-updates
Pin-Priority: 500

Package: *
Pin: release a=stable-security
Pin-Priority: 500

Package: *
Pin: release o=Debian
Pin-Priority: 50
EOF

cat <<EOF > /etc/apt/preferences.d/80_systemd
Package: systemd
Pin: release o=Debian Backports
Pin-Priority: 990

Package: systemd-sysv
Pin: release o=Debian Backports
Pin-Priority: 990

Package: systemd-timesyncd
Pin: release o=Debian Backports
Pin-Priority: 990

Package: libnss-resolve linux-image-amd64
Pin: release o=Debian Backports
Pin-Priority: 990
EOF

# Upgrade
apt upgrade -y
apt autoremove -y avahi-daemon fwupd


# Set sudo/root acls
sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/15-sudo-nopassword

# Setup services
systemctl mask networking
systemctl unmask systemd-timesyncd
systemctl enable open-vm-tools systemd-networkd systemd-timesyncd systemd-resolved cloud-init

# Basic network
rm -f /etc/network/interfaces
cat <<EOF > /etc/systemd/network/ens192.network
[Match]
Name=ens192

[Link]
MTUBytes=1500

[Network]
DHCP=yes
IPv6LinkLocalAddressGenerationMode=eui64
EOF

# Setup Cloud-Init
cat <<EOF > /etc/cloud/cloud.cfg.d/10_network.cfg
network:
  config: disabled
EOF

echo "datasource_list: [ 'VMware' ]" > /etc/cloud/cloud.cfg.d/05_datasource.cfg