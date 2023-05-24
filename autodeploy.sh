#!/bin/bash

arr=('v1','v2','v3');
jointox() {
x="$2"
for (( i=3; i <= $#; i++ )); do
    x="$x$1${!i}"
done
}

jointox ',' "\"${arr[@]}\""

command=($@) 2

#autodeploy deploy argument
if [ "${command[0]}" == "deploy" ]
then
    bash /etc/autoDeploy/deploy.sh "{command[@]/${command[0]}}"
fi

if [ "${command[0]}" == "remove" ]
then
    bash /etc/autoDeploy/remove.sh "{command[@]/${command[0]}}"
fi

if [ "${command[0]}" == "add" ]
then
    if [ "${command[1]}" == "node" ]
    then
        bash /etc/autoDeploy/addVersion/node.sh "${command[2]}"
    else
        bash /etc/autoDeploy/addVersion/php.sh "${command[2]}"
    fi
fi

if [ "${command[0]}" == "stop" ]
then
    systemctl stop "${command[1]}"
    systemctl disable "${command[1]}"
    rm "/etc/nginx/sites-enabled/${command[1]}"
    systemctl reload nginx
fi

if [ "${command[0]}" == "start" ]
then
    systemctl start "${command[1]}"
    systemctl enable "${command[1]}"
    ln -s "/etc/nginx/sites-available/${command[1]}" /etc/nginx/sites-enabled/
    systemctl reload nginx
fi

if [ "${command[0]}" == "restart" ]
then
    systemctl restart "${command[1]}"
fi

if [ "${command[0]}" == "version" ]
then
    if [ "${command[1]}" == "node" ]
    then
        bash /etc/autoDeploy/addVersion/node.sh "${command[2]}"
    else
        bash /etc/autoDeploy/addVersion/php.sh "${command[2]}"
    fi
fi


versionPhp=($(ls /etc/php/));
versionNode=($(ls ~root/.nvm/versions/node/));