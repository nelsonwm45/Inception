# Since debian 12 (Bookworm) is the current stable, Debian 11 (Bullseyes) is penultimate stable version of debian
FROM debian:bullseye

# Update and Install MariaDB && clean APT cache to keep final image smaller
RUN apt-get update -y && apt-get upgrade -y \
	&& apt-get install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

# Create directories for permissions
RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld


# Copy strict
COPY tools/mysql-setup.sh /usr/local/bin/mysql-setup.sh
RUN chmod +x /usr/local/bin/mysql-setup.sh

# Copy confid file to override bind-address
COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/mariadb.conf

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/mysql-setup.sh" ]