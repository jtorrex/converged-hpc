#!/bin/bash

# Install MAAS
sudo snap install --channel=3.4 maas
sudo apt-get install postgresql -y

export MAAS_DBUSER=admin
export MAAS_DBPASS=admin
export MAAS_DBNAME=maas
export HOSTNAME=127.0.0.1

sudo -i -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sudo -i -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
sudo echo "127.0.0.1    maas    admin    0/0     md5" >> /etc/postgresql/15/main/pg_hba.conf
sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS_DBNAME"
sudo maas config --maas-url http://192.168.56.200:5240/MAAS

# create kubernetes cluster
kubeadm config images pull
kubeadm init --apiserver-advertise-address=192.168.56.200 --apiserver-cert-extra-sans=192.168.56.200 --pod-network-cidr=172.16.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# backup configuration
mkdir /vagrant/config > /dev/null 2> /dev/null
cp /etc/kubernetes/admin.conf /vagrant/config > /dev/null 2> /dev/null
cp /vagrant/resources/worker.txt /vagrant/scripts/worker.sh
kubeadm token create --ttl 24h0m0s --print-join-command >> /vagrant/scripts/worker.sh

# install calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 172.16.0.0\/16/g' custom-resources.yaml
kubectl apply -f custom-resources.yaml
rm -f custom-resources.yaml > /dev/null 2> /dev/null

# install kustomize
mkdir -p /usr/local/bin
cd /usr/local/bin
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

# install helm version 3
cd ~
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

