#!/usr/bin/env bash
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

mkdir -p /opt

cd /tmp

apt-get install -y php-mysql php-xml

rm -rf phpmyadmin


apt-get install -y wget unzip composer php-mysql php-xml jq
VERSION=$(curl -s https://api.github.com/repos/phpmyadmin/phpmyadmin/releases/latest | jq -r .tag_name | sed 's/RELEASE_//; s/_/./g')
wget https://files.phpmyadmin.net/phpMyAdmin/$VERSION/phpMyAdmin-$VERSION-all-languages.zip
unzip phpMyAdmin-$VERSION-all-languages.zip
rm phpMyAdmin-$VERSION-all-languages.zip

rm -rf /opt/phpmyadmin
mv phpMyAdmin-$VERSION-all-languages /opt/phpmyadmin
cd /opt/phpmyadmin

rm -f config.inc.php

ln -s /etc/phpmyadmin/config.inc.php .

apt-get install -y php-fpm

chown www-data:www-data .

SERVICE=$(basename $(find /etc/systemd -name "php*fpm.service" -print -quit))

systemctl enable --now $SERVICE
systemctl restart $SERVICE || systemctl start $SERVICE

systemctl reload nginx
