# PHP 8.5.12 built from source with docker-library/php's 8.5/trixie/fpm Dockerfile (9dac3d0).

FROM debian:trixie-slim@sha256:f6b08b09a05725f9431502d3b5714f5c4576e82c1a84fa1debe0c24a7e0c3ec4

# Prevent Debian's PHP packages from being installed.
RUN set -eux; \
	{ \
		echo 'Package: php*'; \
		echo 'Pin: release *'; \
		echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php

# Dependencies required for running phpize.
ENV PHPIZE_DEPS="autoconf dpkg-dev file g++ gcc libc-dev make pkg-config re2c"

# Persistent runtime dependencies.
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
		xz-utils \
	; \
	apt-get dist-clean

ENV PHP_INI_DIR=/usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# Allow running as an arbitrary user.
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 1777 /var/www/html

# Stack protector, position-independent executable, -O2, sorted linker hash buckets
# and large file support.
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS="1198C0117593497A5EC5C199286AF1F9897469DC 49D9AF6BC72A80D6691719C8AA23F5BE9C7097D4 D95C03BC702BE9515344AE3374E44BC9067701A5"

ENV PHP_VERSION=8.5.12
ENV PHP_URL="https://www.php.net/distributions/php-8.5.12.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-8.5.12.tar.xz.asc"
ENV PHP_SHA256="08bc2eba2a588654ade1357174aa646b761556c862dda0678345ee29ed481209"

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends gnupg; \
	apt-get dist-clean; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	curl -fsSL -o php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	\
	curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
	export GNUPGHOME="$(mktemp -d)"; \
	for key in $GPG_KEYS; do \
		gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	done; \
	gpg --batch --verify php.tar.xz.asc php.tar.xz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY docker-php-source /usr/local/bin/

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libargon2-dev \
		libcurl4-openssl-dev \
		libonig-dev \
		libreadline-dev \
		libsodium-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		zlib1g-dev \
	; \
	\
	export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
# Shown as the build provider and uname in phpinfo().
		PHP_BUILD_PROVIDER='https://github.com/docker-library/php' \
		PHP_UNAME='Linux - Docker' \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
# PHP's configure looks for the curl headers in /usr/include/curl.
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \
	case "$gnuArch" in \
		'i686-linux-'*) \
			# Zend JIT needs SSE2, so use the SSE floating-point unit on i686.
			export \
				CFLAGS="$CFLAGS -msse2 -mfpmath=sse" \
				CPPFLAGS="$CPPFLAGS -msse2 -mfpmath=sse" \
			; \
			;; \
	esac; \
	test "$PHP_INI_DIR" != "${PHP_INI_DIR%/php}"; \
	./configure \
		--build="$gnuArch" \
		--sysconfdir="${PHP_INI_DIR%/php}" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# Make invalid configure flags fatal instead of warnings.
		--enable-option-checking=fatal \
		\
		--with-mhash \
		\
		--with-pic \
		\
# Built in, because pecl can't use mbstring as a shared extension.
		--enable-mbstring \
# Built in, because mysqlnd is a plugin for several extensions.
		--enable-mysqlnd \
		--with-password-argon2 \
		--with-sodium=shared \
# Always build against the system sqlite3.
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		\
		--with-curl \
		--with-iconv \
		--with-openssl \
		--with-readline \
		--with-zlib \
		\
# phpdbg is a CLI debugger, not suitable for an FPM stack.
		--disable-phpdbg \
		\
# pecl and pear need an explicit --with-pear since PHP 7.4.
		--with-pear \
		\
		--with-libdir="lib/$debMultiarch" \
		\
		--disable-cgi \
		\
		--enable-fpm \
		--with-fpm-user=www-data \
		--with-fpm-group=www-data \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find \
		/usr/local \
		-type f \
		-perm '/0111' \
		-exec sh -euxc ' \
			strip --strip-all "$@" || : \
		' -- '{}' + \
	; \
	make clean; \
	\
# Keep the example php.ini files next to the active config.
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -rt dpkg-query --search \
# Ignores diversions; a .so file rarely belongs to more than one package.
		| awk 'sub(":$", "", $1) { print $1 }' \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	apt-get dist-clean; \
	\
# Update pecl channel definitions.
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
	\
# smoke test
	php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

# sodium is built as a shared module, so enable it.
RUN docker-php-ext-enable sodium

WORKDIR /var/www/html

RUN set -eux; \
	cd "${PHP_INI_DIR%/php}"; \
	\
	cp -v php-fpm.conf.default php-fpm.conf; \
	cp -v php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	\
	# comment out localhost-only listen address
	grep -E '^listen = 127.0.0.1:9000' php-fpm.d/www.conf; \
	sed -ri 's/^(listen = 127.0.0.1:9000)/;\1/' php-fpm.d/www.conf; \
	grep -E '^;listen = 127.0.0.1:9000' php-fpm.d/www.conf; \
	\
	{ \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192'; \
		echo; \
		echo '[www]'; \
		echo '; php-fpm closes STDOUT on startup, so sending logs to /proc/self/fd/1 does not work.'; \
		echo '; https://bugs.php.net/bug.php?id=73886'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
		echo 'decorate_workers_output = no'; \
		echo; \
		echo '; default listen address for easy override in later php-fpm.d/*.conf files'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/docker.conf; \
	{ \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '; the [www] ini section below is for backwards compatibility and will be removed in 8.6+'; \
		echo '[www]'; \
	} | tee php-fpm.d/zz-docker.conf; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
	{ \
		echo '; https://github.com/docker-library/php/issues/878#issuecomment-938595965'; \
		echo 'fastcgi.logging = Off'; \
	} > "$PHP_INI_DIR/conf.d/docker-fpm.ini"

# Stop php-fpm gracefully.
STOPSIGNAL SIGQUIT

EXPOSE 9000

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
    libicu76 \
    libmemcached11 \
    libmemcachedutil2 \
    libpq5 \
    libzip5 \
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
  # Retry each extension: pecl.php.net returns 5xx errors under load.
  && for ext in memcached redis; do \
    for attempt in 1 2 3 4 5; do \
      pecl install "$ext" && break; \
      [ "$attempt" -lt 5 ] || exit 1; \
      sleep 15; \
    done; \
  done \
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

# Copy Composer.
COPY --from=composer:latest@sha256:c7f68260503e3c1f0ece10bdbe84519fd98d48ba091f2c02f16ea94a7faae337 /usr/bin/composer /usr/local/bin/composer

# Copy MinIO client.
COPY --from=pgsty/mc:latest@sha256:ce62c9053c69ce12a527a322345b5ad9f44b5f8a7b8189f82e516f2e3f30f1d8 /usr/bin/mc /usr/bin/mc

# Copy pocketcron.
COPY --from=ghcr.io/angrybytes/pocketcron@sha256:d3c0dc1abbff683809a694ea7df80adcfd87e1ed6545795dc3ae6d554966cae2 /usr/bin/pocketcron /usr/bin/pocketcron

# Copy configuration files and scripts.
COPY usrlocal/ /usr/local/
COPY etc/ /etc/

# Image configuration.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["supervisord"]
