#!/bin/bash
mkdir /var/repoShNode
mkdir /etc/autoDeploy

cp *.sh /etc/autoDeploy/
chmod ug+x /etc/autoDeply/autodeploy.sh

ln -s /etc/autoDeploy/autodeploy.sh /bin/autodeploy
