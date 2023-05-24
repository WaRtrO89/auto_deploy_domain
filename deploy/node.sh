#!/bin/bash

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
version="$4";
type="$5";
#---------------

export PATH="/root/.nvm/versions/node/$version/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

echo "==================================" >> $log;
echo "[$(date)] - (INFO) - INSTALL NODE - $port - $subdomain - $repo" >> $log;
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

"/root/.nvm/versions/node/$version/bin/npm" install >> $log;

echo "[$(date)] - (NPM) - Install'ok'" >> $log;


cat << EOF > "$nginx/sites-available/$subdomain.$domain";
server{
        listen 80;
        server_name $subdomain.$domain;
        root $racine$subdomain.$domain;
        location / {
                include proxy_params;
                proxy_pass http://$subdomain.$domain;
        }
}
EOF

echo "[$(date)] - (NGINX) - Config VirtualHost Create 'ok'" >> $log;

cat << EOF >> "$nginx/conf-enabled/0-proxy.conf";

upstream $subdomain.$domain{
        server 127.0.0.1:$port;
}
EOF

echo "[$(date)] - (NGINX) - Config Proxy Create 'ok'" >> $log;

ln -s "$nginx/sites-available/$subdomain.$domain" "$nginx/sites-enabled/$subdomain.$domain"

echo "[$(date)] - (NGINX) - Alias Enabled VirtualHost 'ok'" >> $log;

cat << EOF > "$repoSh/$subdomain.$domain.sh";
#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

cd $racine$subdomain.$domain/
/root/.nvm/versions/node/v16*/bin/npm run dev -- -p $port
EOF

echo "[$(date)] - (BASH) - Start File Create 'ok'" >> $log;

chmod ug+x "$repoSh/$subdomain.$domain.sh"

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
