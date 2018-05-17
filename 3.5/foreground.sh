#!/bin/bash

source /etc/apache2/envvars

# logs should go to stdout / stderr
set -ex \
	&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log"

apache2 -D FOREGROUND
