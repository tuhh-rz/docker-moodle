FROM ubuntu:20.04

ARG VERSION=${VERSION}
ENV VERSION=$VERSION
RUN echo $VERSION

ARG DOWNLOAD=${DOWNLOAD}
ENV DOWNLOAD=$DOWNLOAD
RUN echo $DOWNLOAD

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade

# Basic Requirements
RUN apt-get -y install python-setuptools cron curl git unzip

# Moodle Requirements
RUN apt-get -y install \
    apache2 \
    curl \
    libapache2-mod-php \
    php \
    php-curl \
    php-gd \
    php-intl \
    php-ldap \
    php-mbstring \
    php-mysql \
    php-pgsql \
    php-soap \
    php-xml \
    php-xmlrpc \
    php-zip \
    supervisor \
    rsync \
    wget

# RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./conf/supervisord.conf /etc/supervisord.conf

RUN mkdir -p /etc/apache2/ssl

RUN curl $DOWNLOAD \
  | tar -xzC /tmp

#RUN chown -R www-data:www-data /var/www/moodle
RUN chmod 755 /start.sh /etc/apache2/foreground.sh

# Crontab
#RUN echo "*/5 * * * * su -s /bin/bash -c '/usr/bin/php /var/www/html/moodle/admin/cli/cron.php' www-data >/dev/null 2>&1" >> /var/spool/cron/crontabs/root
RUN echo "*/5 *   * * *   www-data        /usr/bin/php /var/www/html/moodle/admin/cli/cron.php" >> /etc/crontab

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]

LABEL \
    de.tuhh.ci_repository_url=$CI_REPOSITORY_URL \
    de.tuhh.ci_commit_short_sha=$CI_COMMIT_SHORT_SHA \
    de.tuhh.build-date=$BUILD_DATE \
    de.tuhh.version=$VERSION
