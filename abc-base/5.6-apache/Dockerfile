FROM php:5.6-apache
MAINTAINER Angry Bytes <info@angrybytes.com>

# Install apt packages.
RUN apt-get update -y \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libmemcached-dev \
    && rm -r /var/lib/apt/lists/*

# Enable Apache modules.
RUN a2enmod \
    rewrite

# Install PHP extensions.
RUN docker-php-ext-install \
    exif \
    gd \
    mbstring \
    mcrypt \
    pcntl \
    pdo_mysql \
    zip

# Install PECL extensions.
RUN pecl install \
    memcached

# Install composer. The COMPOSER_HOME is for compatibility with the
# composer/composer image. Ensure it exists, so users can copy in auth.json.
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer \
    && mkdir -p /root/composer
ENV COMPOSER_HOME /root/composer
