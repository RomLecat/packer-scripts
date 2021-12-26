#!/bin/bash
set -e
set -x

# Partition disk
sfdisk "/dev/sda" <<EOF
label: gpt
size=200MiB, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
             type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF

# Format and mount partitions
mkfs.fat -F32 /dev/sda1
mkfs.xfs -L arch_os /dev/sda2
mount /dev/sda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot

# Enable NTP
timedatectl set-ntp true

# Setup mirrors
reflector --country France --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Setup base system and applications
pacstrap /mnt base base-devel linux linux-firmware man openssh sudo vim efibootmgr open-vm-tools xfsprogs python3 inetutils

# Setup fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash