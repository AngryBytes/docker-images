FROM php:7.1-fpm-alpine

# Install dependencies and PHP extensions.
RUN set -x \
 && apk update \
 && apk add \
        freetype \
        icu-libs \
        libjpeg-turbo \
        libpng \
        libwebp \
        nginx \
        pcre \
        tini \
 && apk add --virtual .build-deps \
        $PHPIZE_DEPS \
        freetype-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        pcre-dev \
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
        intl \
        mbstring \
        pcntl \
        pdo_mysql \
        zip \
 && pecl install \
        redis \
 && docker-php-ext-enable \
        redis \
 && apk del .build-deps \
 && rm -r \
        /var/cache/apk/* \
        /tmp/pear \
 # Disable PHP-FPM access logging, because nginx already logs for us.
 && sed -i \
        -e 's/^access\.log/;access.log/g' \
        /usr/local/etc/php-fpm.d/docker.conf

# Configure nginx.
EXPOSE 80
COPY nginx/ /etc/nginx/

# Add the entry script, starting nginx and php-fpm.
# Use tini, so nginx reparents itself to a proper init.
COPY bin/ /usr/local/bin/
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["abc-start"]

# Install composer. The variables here match the `composer/composer` images.
ENV COMPOSER_HOME /composer
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer \
    && mkdir -p $COMPOSER_HOME

# Config and data shared between project versions.
VOLUME /shared
