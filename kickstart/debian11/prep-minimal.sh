#!/bin/bash
cat <<EOF > /etc/apt/preferences.d/80_kernel
Package: linux-image-amd64
Pin: release o=Debian Backports
Pin-Priority: 990

EOF

# Upgrade
apt update
apt dist-upgrade -y

# Set sudo/root acls
sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/15-sudo-nopassword
