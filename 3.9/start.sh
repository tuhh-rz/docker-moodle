#!/bin/bash

SHARED_FOLDER="/usr/local/share/moodle"

# moodledata in den Host plazieren
ln -s "$SHARED_FOLDER"/moodledata /var/www

find "$SHARED_FOLDER"/moodledata ! -user www-data -exec chown www-data: {} +

/usr/sbin/a2enmod ssl

sed -i '/SSLCertificateFile/d' /etc/apache2/sites-available/default-ssl.conf
sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-available/default-ssl.conf
sed -i '/SSLCertificateChainFile/d' /etc/apache2/sites-available/default-ssl.conf

sed -i 's/SSLEngine.*/SSLEngine on\nSSLCertificateFile \/etc\/apache2\/ssl\/cert.pem\nSSLCertificateKeyFile \/etc\/apache2\/ssl\/private_key.pem\nSSLCertificateChainFile \/etc\/apache2\/ssl\/cert-chain.pem/' /etc/apache2/sites-available/default-ssl.conf

sed -i 's/DocumentRoot.*/DocumentRoot \/var\/www\/html\/moodle/' /etc/apache2/sites-available/default-ssl.conf
sed -i 's/DocumentRoot.*/DocumentRoot \/var\/www\/html\/moodle/' /etc/apache2/sites-available/000-default.conf

# Upload size
sed -i 's/upload_max_filesize.*/upload_max_filesize = 1500M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/post_max_size.*/post_max_size = 1500M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/max_execution_time.*/max_execution_time = 600/g' /etc/php/7.4/apache2/php.ini

rsync -au /tmp/moodle /var/www/html

cd /var/www/html/moodle && /usr/bin/php admin/cli/upgrade.php --non-interactive
find /var/www/html ! -user www-data -exec chown www-data: {} +
find /var/www/moodledata ! -user www-data -exec chown www-data: {} +

# It is recommended that the file permissions of config.php are changed after
# installation so that the file cannot be modified by the web server. Please
# note that this measure does not improve security of the server significantly,
# though it may slow down or limit general exploits.
chmod -w /var/www/html/moodle/config.php

ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
