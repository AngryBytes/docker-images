FROM php:8.1-fpm-bullseye

# Install dependencies and PHP extensions.
COPY ./apt /etc/apt
RUN set -x \
  # Setup the nginx debian repo.
  && VERSION_CODENAME="$(awk -F= '/^VERSION_CODENAME=/ { print $2 }' /etc/os-release)" \
  && echo "deb [signed-by=/etc/apt/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian $VERSION_CODENAME nginx" > /etc/apt/sources.list.d/nginx.list \
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
  && rm -fr /usr/local/etc/php-fpm.*

# Configure PHP and PHP FPM.
COPY php/ /usr/local/etc/php/conf.d/
COPY php-fpm.conf /usr/local/etc/

# Configure nginx.
EXPOSE 80
COPY nginx/ /etc/nginx/

# Add the entry script, starting nginx and php-fpm.
# Use tini, so nginx reparents itself to a proper init.
COPY bin/ /usr/local/bin/
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["abc-start"]

# Config and data shared between project versions.
VOLUME /shared
