FROM debian:bullseye

# Update and install PHP extensions required by WordPress
# 'wget' is needed to download the WP-CLI tool.
# 'mariadb-client' is often required by WP-CLI to run database operations.
# -y: automatically answer "yes"
RUN	apt-get update -y && apt-get upgrade -y \
	&& apt-get install -y wget php7.4-fpm php7.4-mysql mariadb-client

# Download WP-CLI
# chmod +x       : Change Mode. '+x' adds the eXecutable permission, allowing us to run it as a program.
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# By default, PHP-FPM listens on a Unix Socket (/run/php/php7.4-fpm.sock).
# Sockets only work if NGINX and PHP are in the SAME container.
# Since they are in different containers, in order to communicate, configure PHP-FPM to listen on port 9000
# sed : Stream EDitor. Used to filter and transform text.
# -i  : In-place. Modifies the file directly rather than printing the result to the screen.
# s   : Substitute command (s/find/replace/flags).
# |   : Delimiter. We use '|' instead of '/' because the file path contains slashes.
# g   : Global. Replaces all occurrences (though there is usually only one 'listen' directive).
# In the file, search for "listen = /run/php/php7.4-fpm.sock", replace with "listen = 9000" for all occurences
# RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|g' /etc/php/7.4/fpm/pool.d/www.conf


COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Create the folder for the socket (even if we use port, php-fpm needs the run folder)
RUN mkdir -p /run/php

# Copy the wp-setup
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/usr/local/bin/wp-setup.sh" ]