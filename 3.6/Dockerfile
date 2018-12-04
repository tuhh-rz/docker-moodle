FROM ubuntu:18.04

ENV MOODLE_VERSION MOODLE_36_STABLE

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
 
# Basic Requirements
RUN apt-get -y install python-setuptools cron curl git unzip

# Moodle Requirements
RUN apt-get -y install apache2 php php-ldap php-gd libapache2-mod-php libapache2-mod-shib2 wget supervisor php-pgsql vim curl php-curl php-xmlrpc php-intl php-xml php-soap php-mbstring php-zip php-mysql

# SSH
RUN apt-get -y install openssh-server
RUN mkdir -p /var/run/sshd

RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./conf/supervisord.conf /etc/supervisord.conf

RUN mkdir -p /etc/apache2/ssl

# RUN mkdir -p /usr/local/share/moodle
# ADD ./conf/config.php /usr/local/share/moodle/config.php

# ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz

# TODO 
# > git repository verwenden
RUN git clone -b ${MOODLE_VERSION} git://git.moodle.org/moodle.git /tmp/moodle
RUN rm -rf /tmp/moodle/.git

# > neuester Branch mit
# git branch -a | awk '/remotes.*STABLE/ {print}' | awk -F/ 'END {print $3}'

#RUN mkdir -p /usr/local/share/moodle/app
# ADD https://download.moodle.org/stable30/moodle-latest-30.tgz /tmp/moodle-latest.tgz
#RUN cd /tmp; tar zxvf moodle-latest.tgz; mv /tmp/moodle /var/www/html

# ADD ./conf/config.php /usr/local/share/moodle/config.php

#RUN chown -R www-data:www-data /var/www/moodle
RUN chmod 755 /start.sh /etc/apache2/foreground.sh

# Crontab
#RUN echo "*/5 * * * * su -s /bin/bash -c '/usr/bin/php /var/www/html/moodle/admin/cli/cron.php' www-data >/dev/null 2>&1" >> /var/spool/cron/crontabs/root
RUN echo "*/5 *   * * *   www-data        /usr/bin/php /var/www/html/moodle/admin/cli/cron.php" >> /etc/crontab

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]

