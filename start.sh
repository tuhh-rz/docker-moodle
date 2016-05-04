#!/bin/bash

SHARED_FOLDER="/usr/local/share/moodle"

chown -Rf www-data.www-data /var/www/html/
chown -Rf www-data.www-data "$SHARED_FOLDER"

ln -s "$SHARED_FOLDER"/config/config.php /var/www/html/moodle/config.php
ln -s "$SHARED_FOLDER"/moodledata /var/www


/usr/local/bin/supervisord -n
