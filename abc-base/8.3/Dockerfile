FROM php:8.3-fpm-bookworm@sha256:99440318a60ac79de18eda58b6c03d2ca9a7cab81d0f4b068afefdc30e1fdec2

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
    libmemcached11 \
    libmemcachedutil2 \
    libpq5 \
    libzip4 \
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
  && docker-php-ext-enable opcache \
  && docker-php-ext-configure gd \
    --with-external-gd \
  && docker-php-ext-configure zip \
    --with-zip \
  && docker-php-ext-configure pdo_mysql \
    --with-zlib-dir=/usr \
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
  && pecl install \
    memcached \
    redis \
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

# Copy MinIO client.
COPY --from=minio/mc:latest@sha256:a7fe349ef4bd8521fb8497f55c6042871b2ae640607cf99d9bede5e9bdf11727 /usr/bin/mc /usr/bin/mc

# Copy pocketcron.
COPY --from=ghcr.io/stephank/pocketcron@sha256:bd5b058816eb0f20236ae429fb26fb7c3f33878a77d5c4bc32f62f45be07af60 /usr/bin/pocketcron /usr/bin/pocketcron

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY nginx/ /etc/nginx/

# Image configuration.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord"]
