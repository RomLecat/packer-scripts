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
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Enable network and SSH
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable vmtoolsd