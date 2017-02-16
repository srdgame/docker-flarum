# Info
FROM debian:8.7
MAINTAINER Dirk Chang <srdgame@gmail.com>
LABEL Description="Flarum forum easy deployment" Vendor="srdgame" Version="1.0"

# Debian Mirrors
RUN sed -i 's/deb\.debian\.org/mirrors\.aliyun\.com/g' /etc/apt/sources.list

# System
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install -q -y curl \
                          git \
                          libcurl3\
                          mysql-server \
                          nginx \
                          openssl \
                          php5 \
                          php5-curl \
                          php5-fpm \
                          php5-gd \
                          php5-mysql \
                          \
                          && \
	apt-get clean && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/bin/composer

# Flarum
RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com
RUN composer create-project flarum/flarum /var/www/flarum --stability=beta
RUN cd /var/www/flarum && composer require srdgame/flarum-ext-auth-erpnext
RUN cd /var/www/flarum && composer require jsthon/flarum-ext-simplified-chinese
RUN chown www-data:www-data -R /var/www/flarum && chmod 777 -R /var/www/flarum

# Nginx
RUN rm -rf /etc/nginx/sites-enabled/*
ADD nginx-flarum.conf /etc/nginx/sites-enabled/flarum.conf

# MySQL
RUN service mysql start && mysql -u root -e 'create database flarum'

# Init script
ADD run-flarum.sh /run-flarum.sh
RUN chmod +x /run-flarum.sh

# Persistence
VOLUME ["/var/lib/mysql"]

# Ports
EXPOSE 80

# Run
CMD /run-flarum.sh
