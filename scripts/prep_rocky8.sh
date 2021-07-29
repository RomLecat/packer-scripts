#!/bin/bash
set -x

# Update
yum update -y

# Remove traces of MAC address and UUID from network configuration
sed -E -i '/^(HWADDR|UUID)/d' /etc/sysconfig/network-scripts/ifcfg-e*

# Password-less sudo
sed -i 's/\s*\(%wheel\s\+ALL=(ALL)\s*ALL\)/# \1/' /etc/sudoers
sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers

# Clean up yum
rpm --rebuilddb
yum clean all

# Remove ssh host keys
rm -rf /etc/ssh/ssh_host*_key*

# Clean up /root
rm -f /root/anaconda-ks.cfg
rm -f /root/install.log
rm -f /root/install.log.syslog
rm -rf /root/.pki

# Clean up /var/log
>/var/log/cron
>/var/log/dmesg
>/var/log/lastlog
>/var/log/maillog
>/var/log/messages
>/var/log/secure
>/var/log/wtmp
>/var/log/audit/audit.log
rm -f /var/log/*.old
rm -f /var/log/*.log
rm -f /var/log/*.syslog

# Clean /tmp
rm -rf /tmp/*
rm -rf /tmp/*.*

# Sysprep
truncate -s 0 > /etc/machine-id
cloud-init clean --logs --seed

# Clear history
history -w
history -c
