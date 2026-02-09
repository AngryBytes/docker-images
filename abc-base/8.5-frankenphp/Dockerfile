FROM dunglas/frankenphp:1-php8.5-trixie@sha256:3995685df1316cca8c3b199b459e0a2fa1706142226fa93de8865222b66604aa

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
COPY --from=ghcr.io/stephank/pocketcron@sha256:bd5b058816eb0f20236ae429fb26fb7c3f33878a77d5c4bc32f62f45be07af60 /usr/bin/pocketcron /usr/bin/pocketcron

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY caddy/ /etc/caddy/

# Image configuration.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord"]
