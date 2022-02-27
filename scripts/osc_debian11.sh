#!/bin/bash

# Upgrades
apt update
apt install -y systemd/bullseye-backports systemd-timesyncd/bullseye-backports libnss-resolve/bullseye-backports linux-image-amd64/bullseye-backports
systemctl enable systemd-networkd systemd-timesyncd systemd-resolved

# Network
cat <<EOF > /etc/cloud/cloud.cfg.d/10-network.cfg
network:
  config: disabled
EOF

cat <<EOF > /etc/systemd/network/ens3.network
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