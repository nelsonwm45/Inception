#!/bin/bash

# Wait for mariadb to be ready
sleep 10

if [ ! -f /var/www/html/wp-config.php]; then
	# Download WordPress
	wp core download --allow-root

	# Create confid using env vars
	wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="mariadb" \
		--allow-root

	# Install WordPress (Create Admin)
	wp core install \
		--url="{DOMAIN_NAME}" \
		--title="Inception" \
		--admin_users="${WP_ADMIN_USER}" \
		--admin_passwords="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root

	# Create second wp user
	wp user create \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root
fi

# Start PHP-FPM in foreground (no daemon)
# In Debian Bullseye, the binary is specific to the version
exec /usr/sbin/php-fpm7.4 -F