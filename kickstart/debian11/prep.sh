#!/bin/bash

apt autoremove -y avahi-daemon fwupd
sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/15-sudo-nopassword
rm -f /etc/network/interfaces
systemctl mask networking
systemctl unmask systemd-timesyncd
systemctl enable open-vm-tools systemd-networkd systemd-timesyncd systemd-resolved
cat <<EOF > /etc/systemd/network/ens192.network
[Match]
Name=ens192

[Link]
MTUBytes=1500

[Network]
DHCP=yes
IPv6LinkLocalAddressGenerationMode=eui64
EOF
cat <<EOF > /etc/cloud/cloud.cfg.d/10-network.cfg
network:
  config: disabled
EOF