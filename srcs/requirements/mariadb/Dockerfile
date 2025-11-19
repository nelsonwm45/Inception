# Since debian 12 (Bookworm) is the current stable, Debian 11 (Bullseyes) is penultimate stable version of debian
FROM debian:bullseye

# 1. Install MariaDB Server.
# 2. Remove apt lists to reduce image size (Best Practice).
# 3. CRITICAL: Remove the default database created by the install.
#    Rationale: If /var/lib/mysql is not empty, our mysql-setup.sh script will
#    assume the DB is already created and skip the user/password setup.
RUN apt-get update -y && apt-get upgrade -y \
	&& apt-get install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql/*

# Create directories for permissions && Socket Setup
# Rationale: MariaDB needs a specific folder for the socket file (mysqld.sock)
# 	to communicate locally. We ensure the 'mysql' user owns it.
RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld


# Initialization Script
# Rationale: Docker containers are isolated. We must copy our setup script
# from the host machine into the container and make it executable.
COPY tools/mysql-setup.sh /usr/local/bin/mysql-setup.sh
RUN chmod +x /usr/local/bin/mysql-setup.sh

# Network Configuration
# Copy config file to override bind-address
# Rationale: The default config binds to 127.0.0.1 (localhost only).
# We copy our custom config (which sets bind-address=0.0.0.0) so 
# WordPress can connect to this database over the Docker network.
COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/mariadb.conf

# Documentation that this service only listen on standard MySQL port
EXPOSE 3306


ENTRYPOINT [ "/usr/local/bin/mysql-setup.sh" ]