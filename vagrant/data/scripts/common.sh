#!/bin/bash

sudo apt-get update
sudo apt-get install -y vim apt-transport-https ca-certificates nfs-common

# configure name resolution
sudo echo "" >> /etc/hosts
sudo echo "# Dev Cluster" >> /etc/hosts
sudo echo "10.10.10.100    head" >> /etc/hosts
sudo echo "10.10.10.101    node01" >> /etc/hosts
sudo echo "10.10.10.102    node02" >> /etc/hosts
sudo echo "10.10.10.103    node03" >> /etc/hosts
sudo echo "10.10.10.110    storage" >> /etc/hosts

# configure root key
sudo mkdir -p $HOME/.ssh
sudo cat /data/config/cluster-ssh-key.pub >> $HOME/.ssh/authorized_keys
