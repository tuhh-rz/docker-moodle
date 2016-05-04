#!/bin/bash

SHARED_FOLDER="/usr/local/share/moodle"

chown -Rf www-data.www-data /var/www/html/
chown -Rf www-data.www-data "$SHARED_FOLDER"

ln -s "$SHARED_FOLDER"/config/config.php /var/www/html/moodle/config.php
ln -s "$SHARED_FOLDER"/moodledata /var/www

chown -Rf www-data.www-data "$SHARED_FOLDER"/moodledata 

/usr/sbin/a2enmod ssl

sed -i '/SSLCertificateFile/d' /etc/apache2/sites-available/default-ssl.conf
sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-available/default-ssl.conf
sed -i '/SSLCertificateChainFile/d' /etc/apache2/sites-available/default-ssl.conf

sed -i 's/SSLEngine.*/SSLEngine on\nSSLCertificateFile \/etc\/apache2\/ssl\/cert.pem\nSSLCertificateKeyFile \/etc\/apache2\/ssl\/private_key.pem\nSSLCertificateChainFile \/etc\/apache2\/ssl\/cert-chain.pem/' /etc/apache2/sites-available/default-ssl.conf

/usr/local/bin/supervisord -n
