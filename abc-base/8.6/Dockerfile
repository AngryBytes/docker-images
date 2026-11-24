# PIE replaces PECL, which the official PHP 8.6 images no longer ship.
FROM ghcr.io/php/pie:1.5.5-bin@sha256:3fca03c16df842d02b654dc382db3756058d9c128064f57cace14f8728779ce9 AS pie

FROM php:8.6-fpm-trixie@sha256:cecc554d2590d11f4177f00af2aa49fd589d7367c8caa5aa97f7d314b0d1bb0a

# Set by the build workflow from .github/apt-upgrades.sh: it changes when Debian has updates
# for this image's packages, so the build reruns the apt steps instead of using the cache.
ARG APT_UPGRADES

# Install dependencies and PHP extensions.
COPY ./apt /etc/apt
RUN --mount=type=bind,from=pie,source=/pie,target=/usr/local/bin/pie \
  set -x \
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
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    libgd3 \
    libgmpxx4ldbl \
    libicu76 \
    libmemcached11 \
    libmemcachedutil2 \
    libpq5 \
    libzip5 \
    "nginx=1.31.9-1~${VERSION_CODENAME}" \
    tini \
    unzip \
    zlib1g \
    supervisor \
    jq \
    pwgen \
    default-mysql-client \
    vim \
  # The pinned nginx version only changes with this file.
  && apt-mark hold nginx \
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
  && pie install php-memcached/php-memcached \
  && pie install phpredis/phpredis \
  # Cleanup.
  && apt-mark auto '.*' > /dev/null \
  && apt-mark manual $savedAptMark > /dev/null \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -r \
    /var/lib/apt/lists/* \
  # Remove PHP FPM config, because we'll replace it.
  && rm -fr /usr/local/etc/php-fpm.* \
  # Ensure nginx directories are writable.
  && rm -fr /var/log/nginx /var/cache/nginx \
  && install -d -o www-data -g www-data /var/log/nginx /var/cache/nginx

# Copy Composer.
COPY --from=composer:latest@sha256:0049ce90b432795bf413a738b073963ada1a689e1a8708104684baafe94586ec /usr/bin/composer /usr/local/bin/composer

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
