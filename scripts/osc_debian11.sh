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
apt update
apt upgrade -y
systemctl enable systemd-networkd systemd-timesyncd systemd-resolved
systemctl mask networking

# Network
sed -i 's/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0"/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0 net.ifnames=0"/g' /etc/default/grub
update-grub

cat <<EOF > /etc/cloud/cloud.cfg.d/10_network.cfg
network:
  config: disabled
EOF

cat <<EOF > /etc/systemd/network/eth0.network
[Match]
Name=ens3

[Link]
MTUBytes=1500

[Network]
DHCP=yes
EOF

# Sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sudo-nopassword

# Cleanup
apt autoremove -y
rm -f /etc/network/interfaces
rm -f /etc/sudoers.d/90-cloud-init-users
echo > /home/outscale/.ssh/authorized_keys 