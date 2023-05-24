#!/bin/bash

#--default variable
domain="domain.tld";
log="/var/log/deploy.log";
racine="/var/www/vhosts/$domain";
nginx="/etc/nginx";
systemd="/etc/systemd/system";
#---------------


#--arguments
port="$1";
subdomain="$2";
repo="$3";
version="$4";
type="$5";
phpPool="/etc/php/$version/fpm/pool.d/"
#---------------

echo "==================================" >> $log;
echo "[$(date)] - (INFO) - INSTALL PHP - $port - $subdomain - $repo" >> $log;
echo "[$(date)] - (GIT) - Connexion Github.com..." >> $log;

cd $racine

#.zip .tar.xz .7z .tar.gz

IF [ "$type" == "git" ]
then
git clone $repo "$subdomain.$domain" "$subdomain.$domain" >> $log;
echo "[$(date)] - (GIT) - clone 'ok'" >> $log;
FI

IF [ "$type" == "tar.gz" ]
then
tar -xf $repo -C $racine/$subdomain.$domain >> $log;
echo "[$(date)] - (UNZIP) - extract 'ok'" >> $log;
FI

IF [ "$type" == "tar.xz" ]
then
tar -xJf $repo -C $racine/$subdomain.$domain >> $log;
echo "[$(date)] - (UNZIP) - extract 'ok'" >> $log;
FI

IF [ "$type" == "zip" ]
then
unzip $repo $racine/$subdomain.$domain >> $log;
echo "[$(date)] - (UNZIP) - extract 'ok'" >> $log;
FI

IF [ "$type" == "7z" ]
then
7z x $repo $racine/$subdomain.$domain >> $log;
echo "[$(date)] - (UNZIP) - extract 'ok'" >> $log;
FI

cd "$subdomain.$domain"

cat << EOF > "$nginx/sites-available/$subdomain.$domain";
server{
        listen 80;
        server_name $subdomain.$domain;
        root $racine$subdomain.$domain;
        
        index index.php index.html index.htm;

        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass unix:/var/run/php/$subdomain.$domain.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }

        location / {
            try_files $uri $uri/ =404;
        }
}
EOF

echo "[$(date)] - (NGINX) - Config VirtualHost Create 'ok'" >> $log;

ln -s "$nginx/sites-available/$subdomain.$domain" "$nginx/sites-enabled/$subdomain.$domain"

cat << EOF > "$phpPool$subdomain.$domain.conf"
[$subdomain.$domain]
user = root
group = root
listen = /var/run/php/$subdomain.$domain.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
EOF

cat << EOF > "$systemd/$subdomain.$domain.service";
[Unit]
Description=App Portfolio $subdomain
Documentation=https://$subdomain.$domain/
After=syslog.target network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=$repoSh/$subdomain.$domain.sh
StandardOutput=syslog
StandardError=syslog
syslogIdentifier=$subdomain-$domain
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "[$(date)] - (SYSTEMD) - Config Auto Start 'ok'" >> $log;

systemctl enable "$subdomain.$domain.service"

systemctl start "$subdomain.$domain.service"

systemctl reload nginx.service

/bin/certbot --nginx -d "$subdomain.$domain"

echo "[$(date)] - (CERTBOT) - Certificate Install 'ok'" >> $log;
