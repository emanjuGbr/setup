#!/bin/bash

genpasswd() {
	openssl rand -hex 32
}

# generate odoo master & postgres password
PW="$(genpasswd 32)"
sed "s/<replace>/$PW/g" odoo/odoo.conf.template > odoo/odoo.conf
sed "s/<replace>/$PW/g" odoo/odoo-config.conf.template > odoo/odoo-config.conf
echo -e "PGPASSWORD=$PW\nPOSTGRES_PASSWORD=$PW" > .env
if [ "$1" == "" ]; then
	echo "please insert filestore path"
fi
STORAGEBOX_PATH="$1"
echo "STORAGEBOX=$STORAGEBOX_PATH" >> .env
# change directory access rights
docker run --rm -t --user root -v $(pwd)/odoo/:/odoo -v $STORAGEBOX_PATH/filestore/:/odoo/filestore odoo:11.0 chown odoo: /odoo -R
docker run --rm -t --user root -v $(pwd)/postgres/data:/postgres postgres:9.6-alpine chown postgres: /postgres -R
docker run --rm -t --user root -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d nginx:alpine chown nginx: /etc/nginx/conf.d -R

# start odoo services
docker-compose up -d
