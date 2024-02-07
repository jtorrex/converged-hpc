#!/bin/bash

sudo apt-get update
sudo apt-get install -y vim apt-transport-https ca-certificates nfs-common

# configure name resolution
echo "" >> /etc/hosts
echo "# Dev Cluster" >> /etc/hosts
echo "10.10.10.100    head" >> /etc/hosts
echo "10.10.10.101    node01" >> /etc/hosts
echo "10.10.10.102    node02" >> /etc/hosts
echo "10.10.10.103    node03" >> /etc/hosts
echo "10.10.10.110    storage" >> /etc/hosts
