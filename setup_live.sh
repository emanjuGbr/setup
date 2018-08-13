#!/bin/bash

genpasswd() {
        local l=$1
        [ "$l" == "" ] && l=16
        tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

# generate odoo master & postgres password
PW="$(genpasswd 32)"
sed "s/<replace>/$PW/g" odoo/odoo.conf.template > odoo/odoo.conf
echo -e "PGPASSWORD=$PW\nPOSTGRES_PASSWORD=$PW" > .env

# change directory access rights
docker run --rm -t --user root -v $(pwd)/odoo/:/odoo odoo:11.0 chown odoo: /odoo -R
docker run --rm -t --user root -v $(pwd)/postgres/data:/postgres postgres:9.6-alpine chown postgres: /postgres -R
docker run --rm -t --user root -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d nginx:alpine chown nginx: /etc/nginx/conf.d -R

# start odoo services
docker-compose up -d
