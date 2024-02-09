#!/bin/bash

# configure kubernetes requirements
swapoff -a

rm -f /swap.img > /dev/null
cp /etc/fstab /etc/fstab.bak
egrep -v swap /etc/fstab.bak > /etc/fstab

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

systemctl stop ufw
systemctl disable ufw

# install & configure docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
do 
    NEEDRESTART_MODE=a apt-get remove -y $pkg 2> /dev/null
done

NEEDRESTART_MODE=a apt-get update

NEEDRESTART_MODE=a apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

NEEDRESTART_MODE=a apt-get update
NEEDRESTART_MODE=a apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker vagrant > /dev/null

echo "{" >> /etc/docker/daemon.json
echo "    \"insecure-registries\" : [\"docker-registry:5000\", \"docker-registry.kubernetes.lab:5000\"]" >> /etc/docker/daemon.json
echo "}" >> /etc/docker/daemon.json

systemctl daemon-reload
systemctl enable docker.service > /dev/null
systemctl enable containerd.service > /dev/null

# set cgroup driver
mv /etc/containerd/config.toml /etc/containerd/config.toml.bak 2> /dev/null
sh -c "containerd config default" > /etc/containerd/config.toml
sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml

# troubleshoot containerd error
cp /etc/containerd/config.toml /etc/containerd/config.toml.2
sed 's/disabled_plugins/#disabled_plugins/g' /etc/containerd/config.toml.2 > /etc/containerd/config.toml
rm -f /etc/containerd/config.toml.2 > /dev/null 2> /dev/null

systemctl restart containerd
