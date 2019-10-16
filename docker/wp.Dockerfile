FROM wordpress:php7.3-apache

# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

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