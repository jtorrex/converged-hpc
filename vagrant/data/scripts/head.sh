#!/bin/bash

echo 'Installing k0s'
curl -sSLf https://get.k0s.sh | sudo sh
mkdir -p /etc/k0s
k0s config create > /etc/k0s/k0s.yaml
sudo k0s install controller -c /etc/k0s/k0s.yaml

echo 'Starting k0s'
sudo k0s start

echo 'Generating autocompletion'
echo 'source <(k0s completion bash)' >>~/.bashrc

echo 'Waiting to start services'
sleep 60
sudo k0s status

echo 'Generating kubectl config'
mkdir -p $HOME/.kube
k0s kubeconfig admin > ~/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo 'Installing kubectl'
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo 'Creating worker join command'
sudo k0s token create --role=worker > /data/config/worker-token.txt

echo "install kustomize"
mkdir -p /usr/local/bin
cd /usr/local/bin
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

echo "install helm version 3"
cd ~
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
