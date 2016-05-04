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

RUN mkdir -p /usr/local/share/moodle/config
ADD ./conf/config.php /usr/local/share/moodle/config/config.php

#ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz
ADD https://download.moodle.org/stable30/moodle-latest-30.tgz /var/www/moodle-latest.tgz
RUN cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html
RUN chown -R www-data:www-data /var/www/html/moodle
RUN chmod 755 /start.sh /etc/apache2/foreground.sh

# Crontab
RUN echo "* * * * * su -s /bin/bash -c '/usr/bin/php /var/www/html/moodle/admin/cli/cron.php' www-data >/dev/null 2>&1" >> /var/spool/cron/crontabs/root

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]

