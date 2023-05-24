#!/bin/bash


IFS=' ' read -r -a array <<< "$@"

apt update -y
apt install libapache2-mod-php${array[0]} php${array[0]} -y
apt install php${array[0]}-{curl,gd,intl,memcache,xml,zip,mbstring,memcached,opcache,mcrypt,xmlrpc,bcmath} -y
apt install php${array[0]}-fpm php${array[0]}-mysql -y
cd ../