#!/bin/bash

# Set root password
echo "root:root" | chpasswd

# Set apt preferences
cat <<EOF > /etc/apt/preferences.d/90_default
Package: *
Pin: release a=stable
Pin-Priority: 500

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

cat <<EOF > /etc/apt/preferences.d/80_kernel
Package: linux-image-amd64 linux-image-cloud-amd64 linux-headers-amd64
Pin: release o=Debian Backports
Pin-Priority: 990
EOF

cat <<EOF > /etc/apt/preferences.d/80_systemd
Package: libsystemd0 systemd systemd-sysv systemd-timesyncd systemd-resolved libnss-systemd libpam-systemd
Pin: release o=Debian Backports
Pin-Priority: 990
EOF

# Upgrade
apt update
apt install -y systemd-timesyncd
apt upgrade -y
apt autoremove -y
systemctl enable --now systemd-networkd systemd-timesyncd systemd-resolved
systemctl mask networking ifup@.service ifup@eth0.service

# Network
sed -i "s/GRUB_CMDLINE_LINUX=\"\(.*\)\"/GRUB_CMDLINE_LINUX=\"\1 net.ifnames=0\"/" /etc/default/grub
cat /etc/default/grub
update-grub

cat <<EOF > /etc/cloud/cloud.cfg.d/10_network.cfg
network:
  config: disabled
EOF

cat <<EOF > /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Link]
MTUBytes=1500

[Network]
DHCP=yes
EOF

# Sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sudo-nopassword

# Cleanup
rm -f /etc/network/interfaces
rm -f /etc/sudoers.d/90-cloud-init-users
echo > /home/outscale/.ssh/authorized_keys
