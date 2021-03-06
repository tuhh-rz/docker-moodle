FROM ubuntu:20.04

ARG VERSION=${VERSION}
ENV VERSION=$VERSION
RUN echo $VERSION

ARG DOWNLOAD=${DOWNLOAD}
ENV DOWNLOAD=$DOWNLOAD
RUN echo $DOWNLOAD

LABEL \
  de.tuhh.ci_repository_url=$CI_REPOSITORY_URL \
  de.tuhh.ci_commit_short_sha=$CI_COMMIT_SHORT_SHA \
  de.tuhh.build-date=$BUILD_DATE \
  de.tuhh.version=$VERSION \
  de.tuhh.eol=20250501

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
  rsync \
  supervisor \
  wget

ADD ./setup.sh /setup.sh
ADD ./apache.sh /apache.sh
RUN chmod 755 /setup.sh /apache.sh

ADD ./conf/supervisord.conf /etc/supervisord.conf

RUN curl $DOWNLOAD \
  | tar -xzC /tmp

RUN mkdir -p /etc/apache2/ssl
RUN /usr/sbin/a2enmod ssl
RUN sed -i '/SSLCertificateFile/d' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i '/SSLCertificateChainFile/d' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i 's/SSLEngine.*/SSLEngine on\nSSLCertificateFile \/etc\/apache2\/ssl\/cert.pem\nSSLCertificateKeyFile \/etc\/apache2\/ssl\/private_key.pem\nSSLCertificateChainFile \/etc\/apache2\/ssl\/cert-chain.pem/' /etc/apache2/sites-available/default-ssl.conf

EXPOSE 80
CMD ["/bin/bash", "/setup.sh"]
