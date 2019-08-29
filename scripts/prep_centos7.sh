#!/bin/bash

# Stop logging
systemctl stop rsyslog

# Log cleanup
logrotate -f /etc/logrotate.conf
rm -f /var/log/*-???????? /var/log/*.gz
rm -f /var/log/dmesg.old
rm -rf /var/log/anaconda
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog
cat /dev/null > /var/log/grubby

# No history
unset HISTFILE
rm -f ~root/.bash_history
history -c

# Update
yum update -y
package-cleanup --oldkernels --count=1
yum clean all

# Password-less sudo
sed -i 's/\s*\(%wheel\s\+ALL=(ALL)\s*ALL\)/# \1/' /etc/sudoers
sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers

# Network interface cleanup
rm -f /etc/udev/rules.d/70*
sed -i '/^(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-ens192

# SSH Cleanup
rm -f /etc/ssh/*key*
history -c

# Sysprep
yum install -y initial-setup
easy_install six
hostnamectl set-hostname localhost.localdomain
cat /dev/null > /etc/machine-id
