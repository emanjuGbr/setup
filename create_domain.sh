#!/bin/bash
set -e
if [[ "$1" == ""  ]];
then
	echo "domain is missing";
	exit 1;
fi
echo "domain: $1"

echo -n "1.) setup new nginx config."

cp nginx/conf.d/odoo.template nginx/conf.d/$1.conf

if [ "$(uname)" == "Darwin" ]; 
then
	echo "Running on Mac OS"
	sed "s/<replace_sn>/$1/g" nginx/conf.d/$1.conf
else 
	echo "Running not on Mac OS"
	sed -i "s/<replace_sn>/$1/g" nginx/conf.d/$1.conf
fi

docker exec -ti setup_nginx_1 nginx -s reload
echo  " ok"
echo -n "2.) create certificate."
docker run --rm -ti --network setup_network --ip 10.18.77.5 -v /etc/letsencrypt:/etc/letsencrypt -v /tmp:/var/log/letsencrypt \
        certbot/certbot certonly \
        --agree-tos \
        -m mahlich@emanju.de \
        --standalone \
        --preferred-challenges http \
        -d $1
echo " ok"
echo -n "3.) activate tls for $1."

if [ "$(uname)" == "Darwin" ]; 
then
	sed "s/#//g" nginx/conf.d/$1.conf
else
	sed -i "s/#//g" nginx/conf.d/$1.conf
fi
	docker exec -ti setup_nginx_1 nginx -s reload
echo " ok"
