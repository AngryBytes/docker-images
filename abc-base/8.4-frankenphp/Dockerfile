FROM dunglas/frankenphp:1-php8.4-trixie@sha256:0de5a32944f72c13b45d183e8e6c53546b8172cec21cc8599e24b12e0661506d

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
COPY --from=pgsty/mc:latest@sha256:6ecdaec70bc5e8cf9d0e9a70c190f3beb1c83f11617ff4333f1fcd71ab1daf18 /usr/bin/mc /usr/bin/mc

# Copy pocketcron.
COPY --from=ghcr.io/angrybytes/pocketcron@sha256:8529a9187d3ae44e04836ad1bb9d1ec499bcc02d6725324a43d035005cc34728 /usr/bin/pocketcron /usr/bin/pocketcron

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY caddy/ /etc/caddy/

# Image configuration.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord"]
