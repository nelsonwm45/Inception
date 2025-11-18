FROM debian:bulleyes

# Update and install PHP extensions required by WordPress
RUN	apt-get update -y && apt-get upgrade -y \
	&& apt-get install -y wget php7.4-fpm php-7.4-mysql mariadb-client

# Download WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on port 9000 (Required!)
# We verify the file location on Bullseye is /etc/php/7.4/fpm/pool.d/www.conf
RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|g' /etc/php/7.4/fpm/pool.d/www.conf

# Create the folder for the socket (even if we use port, php-fpm needs the run folder)
RUN mkdir -p /run/php

# Copy the wp-setup
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/usr/local/bin/wp-setup.sh" ]