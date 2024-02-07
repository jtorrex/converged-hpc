#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y vim apt-transport-https ca-certificates nfs-common

# configure name resolution
echo "" >> /etc/hosts
echo "# Dev Cluster" >> /etc/hosts
echo "192.168.56.200    head" >> /etc/hosts
echo "192.168.56.201    node01" >> /etc/hosts
echo "192.168.56.202    node02" >> /etc/hosts
echo "192.168.56.203    node03" >> /etc/hosts
echo "192.168.56.210    storage" >> /etc/hosts
