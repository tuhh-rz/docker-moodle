Die Datei *Dockerfile*
==

- Basis ist Ubuntu 14.04
- Jeder Build des Images aktualisiert das Basis-System auf den neuesten Stand
- Jeder Build des Images aktualisiert Moodle Minor-Branch
  - Für eine neue Major-Version ist die entsprechende `git clone …`-Zeile anzupassen
- Voraussetzungen für SSL werden erfüllt
  - Die notwendigen Dateien liegen im Unterverzeichnis `conf/certs`
- Cron-Jobs werden eingetragen
- Erstellung eines neuen Images mit

      docker build -t `local/moodle:latest` .

    Der Name des Images `local/moodle:latest` wird in der Datei `docker-compose.yml` verwendet


    FROM ubuntu:14.04

    # Keep upstart from complaining
    RUN dpkg-divert --local --rename --add /sbin/initctl
    RUN ln -sf /bin/true /sbin/initctl

    # Let the conatiner know that there is no tty
    ENV DEBIAN_FRONTEND noninteractive

    RUN apt-get update
    RUN apt-get -y upgrade

    # Basic Requirements
    RUN apt-get -y install python-setuptools curl git unzip

    # Moodle Requirements
    RUN apt-get -y install apache2 php5 php5-ldap php5-gd libapache2-mod-php5 wget supervisor php5-pgsql vim curl libcurl3 libcurl3-dev php5-curl php5-xmlrpc php5-intl php5-mysql

    # SSH
    RUN apt-get -y install openssh-server
    RUN mkdir -p /var/run/sshd

    RUN easy_install supervisor
    ADD ./start.sh /start.sh
    ADD ./foreground.sh /etc/apache2/foreground.sh
    ADD ./conf/supervisord.conf /etc/supervisord.conf

    RUN mkdir -p /etc/apache2/ssl
    ADD ./conf/certs/cert.pem /etc/apache2/ssl/cert.pem
    ADD ./conf/certs/private_key.pem /etc/apache2/ssl/private_key.pem
    ADD ./conf/certs/cert-chain.pem /etc/apache2/ssl/cert-chain.pem

    RUN git clone -b MOODLE_30_STABLE git://git.moodle.org/moodle.git /tmp/moodle

    # TODO
    # newest branch
    # git branch -a | awk '/remotes.*STABLE/ {print}' | awk -F/ 'END {print $3}'

    RUN chmod 755 /start.sh /etc/apache2/foreground.sh

    # Crontab
    RUN echo "* * * * * su -s /bin/bash -c '/var/www/html/moodle/admin/cli/cron.php' www-data >/dev/null 2>&1" >> /var/spool/cron/crontabs/root

    EXPOSE 22 80
    CMD ["/bin/bash", "/start.sh"]


Die Datei *docker-compose.yml*
==============================

- Es wird ein laufender Container mit einer *MariaDB*-Installation erwartet
- Der Name dieses Containers lautet im Beispiel `local/moodle:latest`
- Der Host, unter dem dieser Datenbank-Server zu erreichen ist, lautet im Beispiel `db`.
  - Dieser Name wird automatisch im Docker-Container in die Datei `/etc/hosts` eingetragen



    moodle:
      image: 'local/moodle:latest'
      restart: always
      hostname: 'moodle'
      ports:
        - '30080:80'
        - '30443:443'
        - '30022:22'
      volumes:
        - '/docker_volumes/srv/moodle/data:/var/www/moodledata'
        - '/docker_volumes/srv/moodle/app:/var/www/html/moodle'
      external_links:
        - mariadb_mariadb_1:db



Die Datei *start.sh*
==

- Bei jedem Start wird eine Aktualisierung von Moodle durchgeführt
- Durch die Verwendung von `rsync -c …` werden keine Dateien überschrieben, die nachträglich hinzugefügt wurden, z.B. im Web-UI nachträglich installierte Themes.
- Die Dateien, die im Git-Repository enthalten sind werden überschrieben, wenn diese sich geändert haben



    #!/bin/bash

    SHARED_FOLDER="/usr/local/share/moodle"

    chown -Rf www-data.www-data /var/www/html/
    chown -Rf www-data.www-data "$SHARED_FOLDER"

    # moodledata in den Host plazieren
    # ln -s "$SHARED_FOLDER"/moodledata /var/www

    chown -Rf www-data.www-data "$SHARED_FOLDER"/moodledata

    /usr/sbin/a2enmod ssl

    sed -i '/SSLCertificateFile/d' /etc/apache2/sites-available/default-ssl.conf
    sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-available/default-ssl.conf
    sed -i '/SSLCertificateChainFile/d' /etc/apache2/sites-available/default-ssl.conf

    sed -i 's/SSLEngine.*/SSLEngine  on\nSSLCertificateFile\/etc\/apache2\/ssl\/cert.pem\nSSLCertificateKeyFile\/etc\/apache2\/ssl\/private_key.pem\nSSLCertificateChainFile\/etc\/apache2\/ssl\/cert-chain.pem/' /etc/apache2/sites-available/default-ssl.conf

    rsync -rc /tmp/moodle /var/www/html
    chown -Rf www-data.www-data /var/www/html
    chown -Rf www-data.www-data /var/www/moodledata

    ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/

    /usr/local/bin/supervisord -n


TODOs
==

- Das Root-Verzeichnis könnte angepasst werden, so dass kein Pfad in der URL verwendet werden muss, dazu muss aber auch eine bestehende `config.php` angepasst werden

# Shibboleth
