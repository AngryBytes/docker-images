FROM dunglas/frankenphp:1-php8.5-trixie@sha256:b2b64b403c6dbfdcb6cdb78d533ff89d131eb9d5d8aba597e15a46559341f3b4

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
COPY --from=minio/mc:latest@sha256:a7fe349ef4bd8521fb8497f55c6042871b2ae640607cf99d9bede5e9bdf11727 /usr/bin/mc /usr/bin/mc

# Copy pocketcron.
COPY --from=ghcr.io/angrybytes/pocketcron@sha256:8529a9187d3ae44e04836ad1bb9d1ec499bcc02d6725324a43d035005cc34728 /usr/bin/pocketcron /usr/bin/pocketcron

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY etc/ /etc/

# Image configuration.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord"]
