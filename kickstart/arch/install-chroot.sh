#!/bin/bash
set -e
set -x

# Hostname
echo localhost > /etc/hostname
echo 127.0.0.1 localhost.localdomain localhost > /etc/hosts

# Locale
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo LANG="en_US.UTF-8" > /etc/locale.conf

# Create boot env
mkinitcpio -p linux

# Configure users, SSH and sudo
echo -e 'root\nroot' | passwd
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
groupadd sudo
echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo
chmod 440 /etc/sudoers.d/sudo

# Setup bootloader
bootctl install
cat <<EOF > /boot/loader/loader.conf
default  arch
timeout  0
EOF
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root="LABEL=arch_os" rw
EOF
systemctl enable systemd-boot-update

# Setup network interface
cat <<EOF > /etc/systemd/network/ens160.network
[Match]
Name=ens160

[Link]
MTUBytes=1500

[Network]
DHCP=yes
IPv6LinkLocalAddressGenerationMode=eui64
EOF

# Enable network and SSH
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable sshd
systemctl enable vmtoolsd