#!/bin/sh

# Install the database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	# Start MariaDB temporarily to set up users
	/usr/bin/mysqld_safe --datadir=/var/lib/mysql &

	# Wait it to start
	sleep 15

	# Create Database and User Securely using env variables
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
	mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
	mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
	mysql -u root -e "FLUSH PRIVILEGES;"

	# Set Root Password and Shutdown
	mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
	mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
else
	echo "DATABASE WAS ALREADY CREATED!"
fi

# Start MariaDB safely (not infinite loop hack)
# We use exec to replace the shell process with mysqld
exec mysqld_safe --bind-address=0.0.0.0