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

# Copy NGINX configuration files:
#  - /etc/nginx/nginx.conf    : global NGINX config (worker_processes, includes, etc.)
#  - /etc/nginx/conf.d/default.conf : server block that:
#       * listens on 443 with ssl http2;
#       * uses ONLY TLSv1.2 and TLSv1.3, per subject;
#       * forwards traffic to the WordPress php-fpm container (fastcgi_pass / proxy_pass).
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy TLS certificate and private key that NGINX uses for HTTPS on port 443.
# (In a “real” setup you might generate them at runtime, but static files are fine here.)
COPY conf/ssl/server.crt /etc/nginx/ssl/server.crt
COPY conf/ssl/server.key /etc/nginx/ssl/server.key

# Set strict permissions on the private key (only root/NGINX master can read it),
# and standard read permissions on the certificate. This is good security hygiene,
# even though the subject doesn't explicitly test it.
RUN chmod 600 /etc/nginx/ssl/server.key \
	&& chmod 644 /etc/nginx/ssl/server.crt

# Declare that this container exposes only HTTPS (port 443).
# The subject explicitly checks "NGINX can be accessed by port 443 only".
EXPOSE 443

# Run NGINX in the foreground as PID 1.
#  - "daemon off;" keeps it in the foreground (no background fork),
#  - satisfies the subject's rule: NO infinite loops, NO 'tail -f', NO 'sleep infinity'.
CMD ["nginx", "-g", "daemon off;"]
