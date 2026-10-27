FROM dunglas/frankenphp:1-php8.4-trixie@sha256:8d5cfcc9ce4e6b4db887a04cce820801816d7f53e3a6234e98e0120415238a97

# Install dependencies and PHP extensions.
RUN set -x \
  # Symlink supervisord config.
  && ln -s /usr/local/etc/supervisord.conf /etc/ \
  # Web-writable state directory.
  && install -d -o www-data -g www-data /run/www \
  # Empty default crontab.
  && touch /etc/crontab \
  # Run-time dependencies.
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    default-mysql-client \
    jq \
    pwgen \
    supervisor \
    tini \
    unzip \
    vim \
  # Build PHP extensions.
  && install-php-extensions \
    @composer \
    exif \
    gd \
    gettext \
    gmp \
    intl \
    ldap \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    redis \
    zip \
  # Fix up some confusing stuff from the base image.
  && rm -fr /app/public /etc/frankenphp \
  && chown -R www-data:www-data /config /data

# Copy MinIO client.
COPY --from=pgsty/mc:latest@sha256:ce62c9053c69ce12a527a322345b5ad9f44b5f8a7b8189f82e516f2e3f30f1d8 /usr/bin/mc /usr/bin/mc

# Copy pocketcron.
COPY --from=ghcr.io/angrybytes/pocketcron@sha256:d3c0dc1abbff683809a694ea7df80adcfd87e1ed6545795dc3ae6d554966cae2 /usr/bin/pocketcron /usr/bin/pocketcron

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY caddy/ /etc/caddy/

# Image configuration.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord"]
