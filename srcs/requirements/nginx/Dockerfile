# Use the penultimate stable Debian release, as required by the Inception subject
# bullseye (Debian 11) is previous stable release, because current is Debian 12 bookworm
# (penultimate stable Debian/Alpine only, no random base images).
FROM debian:bullseye

# Install only what this NGINX service actually needs:
#  - nginx   : the web server / reverse proxy for WordPress
#  - openssl : TLS support and tools to handle certificates
#  - rm -rf /var/lib/apt/lists/* : clean APT cache to keep the final image smaller
RUN apt-get update \
	&& apt-get install -y nginx openssl \
	&& rm -rf /var/lib/apt/lists/*

# Create the directories that this container is responsible for:
#  - /etc/nginx/ssl  : location of the certificate and private key used by NGINX
#  - /var/www/html   : document root where the WordPress volume will be mounted
RUN mkdir -p /etc/nginx/ssl /var/www/html

# Generate self-signed certificate (TLS)
# req -x509: self signed
# -nodes: no password for key
# -out / -keyout: where to save
# -subj: fills in the certificate info automatically
RUN openssl req -x509 -sha256 -days 365 -nodes \
	-out /etc/nginx/ssl/nchok.crt \
	-keyout /etc/nginx/ssl/nchok.key \
	-subj "/C=MY/ST=SELANGOR/L=PETALINGJAYA/O=42KL/OU=nchok/CN=nchok.42.fr/UID=nchok"

# Copy config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Set permissions
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Declare that this container exposes only HTTPS (port 443).
# The subject explicitly checks "NGINX can be accessed by port 443 only".
EXPOSE 443

# Run NGINX in the foreground as PID 1.
#  - "daemon off;" keeps it in the foreground (no background fork),
#  - satisfies the subject's rule: NO infinite loops, NO 'tail -f', NO 'sleep infinity'.
CMD ["nginx", "-g", "daemon off;"]
