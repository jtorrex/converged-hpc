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

