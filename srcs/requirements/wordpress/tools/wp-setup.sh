#!/bin/bash

# Wait for mariadb to be ready
sleep 10

if [ ! -f /var/www/html/wp-config.php ]; then
	# Download WordPress
	# --allow-root: WP-CLI strictly forbids running as 'root' by default for security. 
	#               Since we are inside a Docker container as root, we MUST use this flag to override the block.
	wp core download --allow-root

	# This connects this container (WordPress) to the Service 1 container (MariaDB).
	# wp config create: WP-CLI command to generate the config file.
	# --dbname: The name of the database to create/use (passed from .env).
	# --dbuser: The database username (passed from .env).
	# --dbpass: The database password (passed from .env).
	# --dbhost="mariadb": CRITICAL. This MUST match the 'container_name' or service name of your database 
	#                     defined in 'docker-compose.yaml'. Localhost (127.0.0.1) would fail because DB is in a different container.
	wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="mariadb" \
		--allow-root

	# Install WordPress (Create Admin)
	wp core install \
		--url="${DOMAIN_NAME}" \
		--title="Inception" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root

	# Create second wp user
	# --role=author: Sets permissions. 'author' is a standard non-admin role. (Cannot be 'administrator').
	wp user create \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root
fi

# Start PHP-FPM in foreground (no daemon)
# In Debian Bullseye, the binary is specific to the version
exec /usr/sbin/php-fpm7.4 -F