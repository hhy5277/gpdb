#!/bin/bash

set -x

# Stop firewall
sudo systemctl stop firewalld

# Disable SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# GPDB Kernel Settings
sudo rm -f /etc/sysctl.d/gpdb.conf
cat <<EOF | sudo tee /etc/sysctl.d/gpdb.conf >/dev/null
# GPDB-Specific Settings

kernel.shmmax = 500000000
kernel.shmmni = 4096
kernel.shmall = 4000000000
kernel.sem = 500 1024000 200 4096
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.ipv4.ip_local_port_range = 1025 65535
net.ipv6.conf.all.disable_ipv6 = 1
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.overcommit_memory = 2
kernel.core_uses_pid = 1
kernel.core_pattern = /tmp/gpdb_cores/core-%e-%s-%u-%g-%p-%t
EOF
sudo sysctl -p /etc/sysctl.d/gpdb.conf

# Creating directory for core files
sudo rm -rf /tmp/gpdb_cores
sudo mkdir -p /tmp/gpdb_cores
sudo chown vagrant:vagrant /tmp/gpdb_cores

# GPDB Kernel Limits
sudo rm -f /etc/security/limits.d/gpdb.conf
cat <<EOF | sudo tee /etc/security/limits.d/gpdb.conf >/dev/null
# GPDB-Specific Settings

* soft nofile 65536
* hard nofile 65536
* soft nproc 131072
* hard nproc 131072
* soft core unlimited
* hard core unlimited
EOF

# Do not destroy user context on logout
sudo sed -i '/RemoveIPC=no/d' /etc/systemd/logind.conf
sudo tee <<< 'RemoveIPC=no' -a /etc/systemd/logind.conf >/dev/null
sudo service systemd-logind restart
