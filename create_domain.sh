#!/bin/bash
set -e

if [ $# -le 1 ];
then
	echo "Arguments are missing -domain -instance type (-c or -l)"
	exit 1;
fi

if [ "$1" == ""  ];
then
	echo "Please enter the domain e.g. demo.emanju.de"
	exit 1;
fi

if [ "$2" == "-c" ] || [ "$2" == "-l" ];
then
	echo "Adding domain: $1 with parameter $2"
else
	echo "Please specify wether this is the config (-c) or live (-l) instance"
	exit 1;
fi



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

if [ "$2" == "-c" ];
then
	$sed "s/odoo:/odoo-config:/g" nginx/conf.d/$1.conf
fi
docker restart setup_nginx_1
