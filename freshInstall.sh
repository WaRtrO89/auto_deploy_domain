#!/bin/bash
mkdir /var/repoShNode
mkdir /etc/autoDeploy

cp *.sh /etc/autoDeploy/
chmod ug+x /etc/autoDeply/autodeploy.sh

ln -s /etc/autoDeploy/autodeploy.sh /bin/autodeploy

apt install nginx -y

systemctl enable nginx
systemctl start nginx

curl -sSL https://packages.sury.org/php/README.txt | bash -x
apt update -y
apt upgrade -y

apt install snapd -y

snap install core
snap refresh core

snap install --classic certbot

ln -s /snap/bin/certbot /bin/certbot

