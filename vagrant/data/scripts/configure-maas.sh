#!/bin/bash
# Configure MAAS
echo "MAAS: create admin"
sudo maas createadmin --username admin --password admin --email admin
echo "MAAS: create admin [DONE]"

echo "MAAS: status" 
sudo maas config
sudo maas status
echo "MAAS: status[DONE]"

echo "MAAS: Exposting APIKEY"
export APIKEY=$(sudo maas apikey --username admin)
echo "MAAS: Exposting APIKEY [DONE]"

# Configure Cluster Network
echo "MAAS: login"
maas login admin 'http://localhost:5240/MAAS/' $APIKEY
echo "MAAS: login [DONE]"

echo "MAAS: configuring subnets. Adding cluster subnet"
export SUBNET=10.10.10.0/24
export FABRIC_ID=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.fabric_id")
export VLAN_TAG=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.vid")
export PRIMARY_RACK=$(maas admin rack-controllers read | jq -r ".[] | .system_id")

maas admin subnet update $SUBNET gateway_ip=10.10.10.100
maas admin ipranges create type=dynamic start_ip=10.10.10.101 end_ip=10.10.10.110
maas admin vlan update $FABRIC_ID $VLAN_TAG dhcp_on=True primary_rack=$PRIMARY_RACK
maas admin maas set-config name=upstream_dns value=1.1.1.1
echo "MAAS: configuring subnets. Adding cluster subnet [DONE]" 

echo "MAAS: configuring subnets. Delete Vagrant subnet"
export SUBNET=192.168.121.0/24
export FABRIC_ID=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.fabric_id")
export VLAN_TAG=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.vid")
export PRIMARY_RACK=$(maas admin rack-controllers read | jq -r ".[] | .system_id")

maas admin subnet delete $SUBNET
echo "MAAS: configuring subnets. Delete Vagrant subnet [DONE]"

echo "MAAS: configuring SSHkeys"
export SSH_KEY=$(cat /data/maas-ssh-key.pub)
maas admin sshkeys create "key=$SSH_KEY"
echo "MAAS: configuring SSHkeys [DONE]"

echo "MAAS: Adding machines"
sudo maas admin machines create hostname=node01 architecture=amd64/generic power_type=manual mac_addresses=3a:15:0b:5f:61:87 commission=true deployed=true
sudo maas admin machines create hostname=node02 architecture=amd64/generic power_type=manual mac_addresses=0a:b5:2c:25:d9:a8 commission=true deployed=true
sudo maas admin machines create hostname=node03 architecture=amd64/generic power_type=manual mac_addresses=92:d7:d0:a1:5d:c9 commission=true deployed=true
echo "MAAS: Adding machines [DONE]"
