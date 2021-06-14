FROM php:8.0-fpm-buster

# Install dependencies and PHP extensions.
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    libgd3 \
    libgmpxx4ldbl \
    libmemcached11 \
    libmemcachedutil2 \
    libpq5 \
    libzip4 \
    nginx-light \
    tini \
    unzip \
    zlib1g \
  && savedAptMark="$(apt-mark showmanual)" \
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
COPY nginx /etc/

# Add the entry script, starting nginx and php-fpm.
# Use tini, so nginx reparents itself to a proper init.
COPY bin/ /usr/local/bin/
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["abc-start"]

# Config and data shared between project versions.
VOLUME /shared
