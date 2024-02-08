#!/bin/bash
export MAAS_DBUSER=admin
export MAAS_DBPASS=admin
export MAAS_DBNAME=maas
export MAAS_URL=http://10.10.10.100:5240/MAAS
export HOSTNAME=127.0.0.1

echo $MAAS_DBUSER
echo $MAAS_DBPASS
echo $MAAS_DBNAME
echo $MAAS_URL
echo $HOSTNAME
echo $SSH_KEY

echo "Installing: MAAS"
sudo snap install --channel=3.4 maas
wait 30
echo "Installing: MAAS [DONE]"

echo "Installing: PostgreSQL"
sudo apt-get install postgresql jq -y
echo "Installing: PostgreSQL [DONE]"

# Install MAAS
echo "PosgreSQL: Creating MAAS USERB and DB"
sudo -i -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sleep 10
sudo -i -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
sleep 10
sudo echo "host   maas    admin    0/0     md5" >> /etc/postgresql/14/main/pg_hba.conf
echo "PosgreSQL: Creating MAAS USERB and DB [DONE]"
sleep 10
echo "MAAS: Initializing"
sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS_DBNAME" --maas-url $MAAS_URL
sleep 30
echo "MAAS: Initializing [DONE]"
