+#!/bin/bash


#--default variable
domain="domain.tld";
log="/var/log/deploy.log";
racine="/var/www/vhosts/$domain";
nginx="/etc/nginx";
systemd="/etc/systemd/system";
repoSh="/var/repoShNode";


#---------------


#--arguments
port="$1";
subdomain="$2";
repo="$3";
engine="$4"; #(node, npm, php, php-fpm)
version="$5";
#---------------
