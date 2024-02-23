#!/bin/bash
echo 'Installing k0s'
curl -sSLf https://get.k0s.sh | sudo sh
mkdir -p /etc/k0s
sudo k0s install worker --token-file /data/config/k8s/worker-token.txt

echo 'Starting k0s'
sudo k0s start
