#!/bin/bash

# install nfs-server
apt-get update
apt-get install -y nfs-kernel-server nfs-common

mkdir -p /data/$pv_name
chown -R nobody:nogroup /data
chmod -R 777 /data

echo "# Cluster Lab" >> /etc/exports
echo "/data 192.168.56.0/255.255.255.0(rw,sync,no_subtree_check)" >> /etc/exports

# configure firewall
# ufw allow from 192.168.56.0/24 to any port nfs
systemctl stop ufw
systemctl disable ufw

systemctl enable nfs-server
systemctl restart nfs-server
