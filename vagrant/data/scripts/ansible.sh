#!/bin/bash
eval $(ssh-agent)
ssh-add /data/config/cluster-ssh-key
sudo apt-get install ansible -y
ansible-playbook -u root -i /data/ansible/inventory.yaml /data/ansible/cluster.yaml
