#!/bin/bash

# Stop logging
systemctl stop rsyslog

# Log cleanup
logrotate -f /etc/logrotate.conf
rm -f /var/log/*-???????? /var/log/*.gz
rm -f /var/log/dmesg.old
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog

# No history
unset HISTFILE
rm -f ~root/.bash_history
history -c

# Update
apt update -y
apt purge -y cloud-init
apt upgrade -y
apt clean -y

# Password-less sudo
sed -i 's/\s*\(%sudo\s\+ALL=(ALL)\s*ALL\)/# \1/' /etc/sudoers
sed -i 's/^#\s*\(%sudo\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers

# Sysprep
cat /dev/null > /etc/machine-id
