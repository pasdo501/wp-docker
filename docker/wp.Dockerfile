FROM wordpress:php7.4-apache

# Install xdebug
RUN pecl install xdebug-3.1.4 && docker-php-ext-enable xdebug

# xdebug config
RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/docker-php-ext-debug.ini


# Install Less for WP-CLI
RUN apt-get update && apt-get -y install less

# Install mysql client (for the wp core install)
RUN apt-get -y install default-mysql-client

# Install WP-CLI
RUN cd ~ && curl -k -L \
    https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp && chmod +x /usr/local/bin/wp

# Configure Sendmail
RUN apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl git &&\
    rm -rf /var/lib/apt/lists/*
RUN curl -Lsf 'https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail
RUN echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog:1025' > /usr/local/etc/php/php.ini

# Change www-data to be same uid & gid as local user -- make this configurable
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
