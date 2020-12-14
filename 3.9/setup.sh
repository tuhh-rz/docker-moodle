#!/bin/bash

export WEBSERVER_ROOT=${WEBSERVER_ROOT:-/var/www/html}

perl -i -pe 's/DocumentRoot.*/DocumentRoot $ENV{'WEBSERVER_ROOT'}/g' /etc/apache2/sites-available/default-ssl.conf
perl -i -pe 's/DocumentRoot.*/DocumentRoot $ENV{'WEBSERVER_ROOT'}/g' /etc/apache2/sites-available/000-default.conf

# Upload size
sed -i 's/upload_max_filesize.*/upload_max_filesize = 1500M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/post_max_size.*/post_max_size = 1500M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/max_execution_time.*/max_execution_time = 600/g' /etc/php/7.4/apache2/php.ini

echo "Sync Moodle into $WEBSERVER_ROOT"
rsync -au /tmp/moodle "$WEBSERVER_ROOT"

echo "Fix permissions"
find "$WEBSERVER_ROOT" ! -user www-data -exec chown www-data: {} +

echo "Install Moodle if neccesary"
export CHMOD=${CHMOD:-2777}
export LANG=${LANG:-en}
export PREFIX=${PREFIX:-mdl_}
export DBPORT=${DBPORT:-3306}

export DATAROOT=${DATAROOT:-/usr/local/share/moodle/moodledata}
mkdir -p "$DATAROOT"
chmod 0777 "$DATAROOT"

su -s /bin/bash -c "/usr/bin/php $WEBSERVER_ROOT/moodle/admin/cli/install.php --non-interactive --agree-license --dataroot=$DATAROOT --chmod=$CHMOD --lang=$LANG --wwwroot=$WWWROOT --dbtype=$DBTYPE --dbhost=$DBHOST --dbname=$DBNAME --dbuser=$DBUSER --dbpass=$DBPASS --dbport=$DBPORT --prefix=$PREFIX --fullname='$FULLNAME' --shortname='$SHORTNAME' --summary='$SUMMARY' --adminuser=$ADMINUSER --adminpass=$ADMINPASS --adminemail=$ADMINEMAIL" www-data

echo "Upgrade Moodle if neccesary"
su -s /bin/bash -c "/usr/bin/php $WEBSERVER_ROOT/moodle/admin/cli/upgrade.php --non-interactive" www-data

echo "Ensure cron.php"
echo "*/5 * * * * www-data /usr/bin/php $WEBSERVER_ROOT/moodle/admin/cli/cron.php" >>/etc/crontab

# It is recommended that the file permissions of config.php are changed after
# installation so that the file cannot be modified by the web server. Please
# note that this measure does not improve security of the server significantly,
# though it may slow down or limit general exploits.
chmod -w "$WEBSERVER_ROOT"/moodle/config.php

ln -sf /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
