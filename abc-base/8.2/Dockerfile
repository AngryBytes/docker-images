FROM php:8.2-fpm-bullseye

# Install dependencies and PHP extensions.
COPY ./apt /etc/apt
RUN set -x \
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
    rsyslog \
    cron \
    jq \
    pwgen \
    default-mysql-client \
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

# Copy MinIO client.
COPY --from=minio/mc:latest /usr/bin/mc /usr/bin/mc

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY nginx/ /etc/nginx/
COPY crontab /etc/crontab

# Image configuration.
EXPOSE 80
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord", "-c", "/usr/local/etc/supervisord.conf"]
