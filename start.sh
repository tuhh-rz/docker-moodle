#!/bin/bash

SHARED_FOLDER="/usr/local/share/moodle"

chown -Rf www-data.www-data /var/www/html/
chown -Rf www-data.www-data "$SHARED_FOLDER"

# Konfiguration in den Host plazieren
#ln -s "$SHARED_FOLDER"/config.php /var/www/html/moodle/config.php


## TODO Plugin-Verzeichnisse im Host plazieren

# > rsync um Aenderungen an den Themes zu übernehmen, die aus einem Release Upgrade stammen
#rsync -rc /var/www/html/moodle/theme "$SHARED_FOLDER"
#rm -rf /var/www/html/moodle/theme
#ln -s "$SHARED_FOLDER"/theme /var/www/html/moodle/theme

# moodledata in den Host plazieren
ln -s "$SHARED_FOLDER"/moodledata /var/www

chown -Rf www-data.www-data "$SHARED_FOLDER"/moodledata 

/usr/sbin/a2enmod ssl

sed -i '/SSLCertificateFile/d' /etc/apache2/sites-available/default-ssl.conf
sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-available/default-ssl.conf
sed -i '/SSLCertificateChainFile/d' /etc/apache2/sites-available/default-ssl.conf

sed -i 's/SSLEngine.*/SSLEngine on\nSSLCertificateFile \/etc\/apache2\/ssl\/cert.pem\nSSLCertificateKeyFile \/etc\/apache2\/ssl\/private_key.pem\nSSLCertificateChainFile \/etc\/apache2\/ssl\/cert-chain.pem/' /etc/apache2/sites-available/default-ssl.conf

sed -i 's/<\/VirtualHost>/<Location \/Shibboleth.sso>\nSetHandler shib\nAuthType None\nRequire all granted\n<\/Location>\n<Directory  \/var\/www\/html\/moodle\/auth\/shibboleth\/index.php>\nAuthType shibboleth\nShibRequireSession On\nrequire valid-user\n<\/Directory>\n<\/VirtualHost>/' /etc/apache2/sites-available/default-ssl.conf

mkdir -p /etc/apache2/shibboleth

#tar zxvf /tmp/moodle-latest.tgz -C /tmp
rsync -rc /tmp/moodle /var/www/html
chown -Rf www-data.www-data /var/www/html
chown -Rf www-data.www-data /var/www/moodledata

ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/

/usr/local/bin/supervisord -n
