FROM php:7.3-fpm-buster

# Install dependencies and PHP extensions.
ENV TINI_VERSION v0.18.0
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    libfreetype6 \
    libgmpxx4ldbl \
    libjpeg62-turbo \
    libmemcached11 \
    libmemcachedutil2 \
    libpng16-16 \
    libpq5 \
    libwebp6 \
    libzip4 \
    nginx-light \
    tini \
    zlib1g \
  && savedAptMark="$(apt-mark showmanual)" \
  && apt-get install -y --no-install-recommends \
    icu-devtools \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libldap2-dev \
    libmemcached-dev \
    libpng-dev \
    libpq-dev \
    libsqlite3-dev \
    libwebp-dev \
    libzip-dev \
    zlib1g-dev \
  && docker-php-ext-enable opcache \
  && docker-php-ext-configure gd \
    --with-webp-dir=/usr \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-zlib-dir=/usr \
    --with-freetype-dir=/usr \
  && docker-php-ext-configure zip \
    --with-zlib-dir=/usr \
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
