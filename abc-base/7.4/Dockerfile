FROM php:7.4-fpm-alpine

RUN set -x \
  # Install dependencies and PHP extensions.
  && apk update \
  && apk add \
    gmp \
    icu-libs \
    libgd \
    libintl \
    libldap \
    libmemcached \
    libsasl \
    libzip \
    nginx \
    oniguruma \
    pcre \
    postgresql-libs \
    sqlite-libs \
    tini \
    unzip \
  && apk add --virtual .build-deps \
    $PHPIZE_DEPS \
    cyrus-sasl-dev \
    gd-dev \
    gettext-dev \
    gmp-dev \
    icu-dev \
    libmemcached-dev \
    libzip-dev \
    oniguruma-dev \
    openldap-dev \
    pcre-dev \
    postgresql-dev \
    sqlite-dev \
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
  && apk del .build-deps \
  && rm -r \
    /var/cache/apk/* \
    /tmp/pear \
  # Fix permissions, because we run as www-data.
  && chmod 755 /var/lib/nginx /var/lib/nginx/tmp/ \
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
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["abc-start"]

# Config and data shared between project versions.
VOLUME /shared
