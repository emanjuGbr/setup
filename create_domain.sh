#!/bin/bash
set -e
if [[ "$1" == ""  ]];
then
	echo "domain is missing";
	exit 1;
fi
echo "domain: $1"

if [ "$(uname)" == "Darwin" ];
then
	echo "Running on Mac OS"
	sed="sed"
else
	echo "Running not on Mac OS"
	sed="sed -i"
fi


echo -n "1.) setup new nginx config."

cp nginx/conf.d/odoo.template nginx/conf.d/$1.conf
$sed "s/<replace_sn>/$1/g" nginx/conf.d/$1.conf


docker exec -ti setup_nginx_1 nginx -s reload
echo  " ok"
echo "2.) create certificate."
{
docker run --rm -ti --network setup_network --ip 10.18.77.5 -v $(pwd)/etc/letsencrypt:/etc/letsencrypt -v /tmp:/var/log/letsencrypt \
        certbot/certbot certonly \
        --agree-tos \
        -m mahlich@emanju.de \
        --standalone \
        --preferred-challenges http \
        -d $1 &&
echo "Certficate created"
} || {
echo "Certficate creation failed"
}
echo "3.) activate tls for $1."

$sed "s/#//g" nginx/conf.d/$1.conf
echo " ok"
if [ "$1" == "config.emanju.de" ];
then
	$sed "s/odoo:/odoo-config:/g" nginx/conf.d/$1.conf
fi
docker exec -ti setup_nginx_1 nginx -s reload
