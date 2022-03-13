#!/bin/bash

apt autoremove -y avahi-daemon ifupdown fwupd
sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sudo-nopassword
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