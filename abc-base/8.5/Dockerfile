FROM php:8.5-fpm-trixie@sha256:baf3ea13a8207fa18e1011bad1016e8b5e59fc974c6966d0efa6f36a16f875f0

# Install dependencies and PHP extensions.
COPY ./apt /etc/apt
RUN set -x \
  # Setup the nginx debian repo.
  && VERSION_CODENAME="$(awk -F= '/^VERSION_CODENAME=/ { print $2 }' /etc/os-release)" \
  && echo "deb [signed-by=/etc/apt/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian $VERSION_CODENAME nginx" > /etc/apt/sources.list.d/nginx.list \
  # Symlink supervisord config.
  && ln -s /usr/local/etc/supervisord.conf /etc/ \
  # Web-writable state directory and nginx listener directory.
  && install -d -o www-data -g www-data /run/www /run/listen \
  # Empty default crontab.
  && touch /etc/crontab \
  # Run-time dependencies.
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    libgd3 \
    libgmpxx4ldbl \
    libicu76 \
    libmemcached11 \
    libmemcachedutil2 \
    libpq5 \
    libzip5 \
    nginx \
    tini \
    unzip \
    zlib1g \
    supervisor \
    jq \
    pwgen \
    default-mysql-client \
    vim \
  && savedAptMark="$(apt-mark showmanual)" \
  # Build-time dependencies.
  && apt-get install -y --no-install-recommends \
    icu-devtools \
    libgd-dev \
    libgmp-dev \
    libicu-dev \
    libldap2-dev \
    libmemcached-dev \
    libonig-dev \
    libpq-dev \
    libsqlite3-dev \
    libzip-dev \
    zlib1g-dev \
  # Build PHP extensions.
  && docker-php-ext-configure gd \
    --with-external-gd \
  && docker-php-ext-configure zip \
    --with-zip \
  && docker-php-ext-configure pdo_mysql \
  && docker-php-ext-install \
    exif \
    gd \
    gettext \
    gmp \
    intl \
    ldap \
    mbstring \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    zip \
  # Retry each extension: pecl.php.net returns 5xx errors under load.
  && for ext in memcached redis; do \
    for attempt in 1 2 3 4 5; do \
      pecl install "$ext" && break; \
      [ "$attempt" -lt 5 ] || exit 1; \
      sleep 15; \
    done; \
  done \
  && docker-php-ext-enable \
    memcached \
    redis \
  # Cleanup.
  && apt-mark auto '.*' > /dev/null \
  && apt-mark manual $savedAptMark > /dev/null \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -r \
    /var/lib/apt/lists/* \
    /tmp/pear \
  # Remove PHP FPM config, because we'll replace it.
  && rm -fr /usr/local/etc/php-fpm.* \
  # Ensure nginx directories are writable.
  && rm -fr /var/log/nginx /var/cache/nginx \
  && install -d -o www-data -g www-data /var/log/nginx /var/cache/nginx

# Copy Composer.
COPY --from=composer:latest@sha256:ca11f643d7791ebdd90a34fc20caf11380d434007ae539a9ea75cd9212e13dca /usr/bin/composer /usr/local/bin/composer

# Copy MinIO client.
COPY --from=pgsty/mc:latest@sha256:b532278b7a3747dbab6fe45eebb40a653efa704e6758e24e9d9ec54fc96c1800 /usr/bin/mc /usr/bin/mc

# Copy pocketcron.
COPY --from=ghcr.io/angrybytes/pocketcron@sha256:d3c0dc1abbff683809a694ea7df80adcfd87e1ed6545795dc3ae6d554966cae2 /usr/bin/pocketcron /usr/bin/pocketcron

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY etc/ /etc/

# Image configuration.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord"]
