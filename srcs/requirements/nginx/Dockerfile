FROM debian:bullseye

# 1. Basic system setup
RUN apt-get update && \
	apt-get install -y \
		nginx \
		openssl \
		ca-certificates && \
	rm -rf /var/lib/apt/lists/*

# 2. Create directories for certs and web files
RUN mkdir -p /etc/nginx/ssl	/var/www/html

# 3) Copy your NGINX config and TLS certs (self-signed in dev)
#    - nginx.conf will:
#         * listen 443 ssl http2;
#         * use ssl_protocols TLSv1.2 TLSv1.3;
#         * proxy_pass to wordpress:9000 (php-fpm via fastcgi);
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf


