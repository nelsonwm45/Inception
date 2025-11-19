#!/bin/sh

echo "DEBUG: Script is running!"
echo "DEBUG: Listing contents of /var/lib/mysql:"
ls -la /var/lib/mysql
echo "DEBUG: Checking if directory /var/lib/mysql/mysql exists..."

# Install the database if it doesn't exist
# -d: Checks if the file exists and is a directory
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "DEBUG: Directory NOT found. Starting installation..."
	
	# mysql_install_db: Initializes the MariaDB data directory and creates the system tables
	# --user=mysql: Runs the initialization process as the 'mysql' user (instead of root) to ensure file permissions are correct
	# --datadir=/var/lib/mysql: Specifies where the database files should be stored (this is your mapped volume)
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	# /usr/bin/mysqld_safe: Starts the MariaDB server wrapper script
	# --datadir=/var/lib/mysql: Explicitly tells the server where to look for data files during this temporary start
	# &: Puts this command in the "background". 
	#	Without '&', the script would pause here forever waiting for the server to stop, and never run the lines below.
	# Start MariaDB temporarily to set up users
	/usr/bin/mysqld_safe --datadir=/var/lib/mysql &

	# Wait it to start
	# This gives the background MariaDB process time to fully start up and be ready to accept connections.
	sleep 15

	# mysql: The command-line client to talk to the database
	# -u root: Connect as the user 'root'
	# -e "...": "Execute". Runs the following SQL string and then exits immediately (non-interactive mode)
	# Create Database and User Securely using env variables
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
	mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

	# SQL: Grants permissions
	# ALL PRIVILEGES: Gives full control (Read/Write/Delete)
	# ON ${MYSQL_DATABASE}.*: Applies to ALL tables (.*) inside your specific database
	# TO '${MYSQL_USER}'@'%': Grants these rights to the user we just created
	mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

	# SQL: Reloads the grant tables in memory so the new permissions take effect immediately
	mysql -u root -e "FLUSH PRIVILEGES;"

	# Set Root Password and Shutdown
	# SQL: Updates the root user
	# 'root'@'localhost': The root user is restricted to 'localhost' (security best practice). It cannot connect from outside the container.
	# IDENTIFIED BY '...': Changes the root password from empty (default) to your secure password
	mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

	# mysqladmin: A utility for performing administrative operations (like shutting down)
	# -u root: Connect as root
	# -p"${MYSQL_ROOT_PASSWORD}": Provides the password immediately (NO SPACE between -p and the password).
	#    Note: We must use the password now because we just set it in the previous line!
	# shutdown: The command to tell the MariaDB server to save data and close.
	mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
else
	echo "DEBUG: Directory FOUND. Skipping installation."
	echo "DATABASE WAS ALREADY CREATED!"
fi

# Start MariaDB safely (not infinite loop hack)
# We use "exec" to replace the shell process with mysqld
# 	Ensure MariaDB becomes PID 1, allowing it to receive signals like "docker stop" correctly

# We bind to address 0.0.0.0, because by default MariaDB/MySQL binds to 127.0.0.1
# 	allowing mariadb to listen to bridge network and wp
# mysql_safe is a wrapper script/manager/monitor of mysql. mysql_safe starts mysqld and watches it.
# 	if mysqld crashes, mysql_safe will notice and restart automatically
exec mysqld_safe --bind-address=0.0.0.0