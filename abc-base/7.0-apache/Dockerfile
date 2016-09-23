FROM php:7.0-apache
MAINTAINER Angry Bytes <info@angrybytes.com>

# Install apt packages.
RUN apt-get update -y \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
    && rm -r /var/lib/apt/lists/*

# Enable Apache modules.
RUN a2enmod \
    rewrite

# Install PHP extensions.
RUN docker-php-ext-enable opcache \
    && docker-php-ext-configure gd \
        --with-jpeg-dir=/usr \
        --with-freetype-dir=/usr \
    && docker-php-ext-install \
        exif \
        gd \
        mbstring \
        pcntl \
        pdo_mysql \
        zip

# Install PECL extensions.
RUN PECL_EXTS="redis" \
    && pecl install $PECL_EXTS \
    && docker-php-ext-enable $PECL_EXTS

# Install composer. The COMPOSER_HOME is for compatibility with the
# composer/composer image. Ensure it exists, so users can copy in auth.json.
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer \
    && mkdir -p /root/composer
ENV COMPOSER_HOME /root/composer
