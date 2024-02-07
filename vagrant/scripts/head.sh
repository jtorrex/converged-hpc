#!/bin/bash
export MAAS_DBUSER='admin'
export MAAS_DBPASS='admin'
export MAAS_DBNAME='maas'
export MAAS_URL='http://10.10.10.100:5240/MAAS'
export HOSTNAME='127.0.0.1'
export SSH_KEY=$(cat /data/maas-ssh-key)

sudo snap install --channel=3.4 maas
sudo apt-get install postgresql jq -y

# Install MAAS
sudo -i -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sudo -i -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
sudo echo "host   maas    admin    0/0     md5" >> /etc/postgresql/14/main/pg_hba.conf
sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS_DBNAME" --maas-url $MAAS_URL

# Configure MAAS
sudo sleep 60
sudo maas createadmin --username admin --password admin --email admin
sudo maas config
sudo maas status
export APIKEY=$(sudo maas apikey --username admin)
maas login admin 'http://localhost:5240/MAAS/' $APIKEY

# Configure Cluster Network
export SUBNET=10.10.10.0/24
export FABRIC_ID=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.fabric_id")
export VLAN_TAG=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.vid")
export PRIMARY_RACK=$(maas admin rack-controllers read | jq -r ".[] | .system_id")

maas admin subnet update $SUBNET gateway_ip=10.10.10.100
maas admin ipranges create type=dynamic start_ip=10.10.10.101 end_ip=10.10.10.105
maas admin vlan update $FABRIC_ID $VLAN_TAG dhcp_on=True primary_rack=$PRIMARY_RACK
maas admin maas set-config name=upstream_dns value=1.1.1.1
maas admin sshkeys create "key=$SSH_KEY"

