FROM alpine

ENV NSD_VERSION 4.3.2
ENV NSD_SHA256 5b5cee2f80ed451f19e02dee620c71a98a781bd72a55810e0acc925fecaa8329

RUN set -x \
 && apk update \
 && apk add \
        openssl \
        libevent \
 && apk add --virtual .build-deps \
        curl \
        gcc \
        make \
        coreutils \
        libc-dev \
        openssl-dev \
        libevent-dev \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fSL "http://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz" -o "nsd-${NSD_VERSION}.tar.gz" \
 && echo "${NSD_SHA256} *nsd-${NSD_VERSION}.tar.gz" | sha256sum -c - \
 && tar -xf "nsd-${NSD_VERSION}.tar.gz" \
 && rm "nsd-${NSD_VERSION}.tar.gz" \
 && ( \
     cd "nsd-${NSD_VERSION}" \
     && ./configure \
         --prefix=/usr/local \
         --sysconfdir=/etc \
         --localstatedir=/var \
         --enable-ratelimit \
     && make -j "$(nproc)" \
     && make install \
 ) \
 && apk del .build-deps \
 && rm -fr \
        /var/cache/apk/* \
        "nsd-${NSD_VERSION}" \
 && addgroup -S nsd \
 && adduser -S -D -H -G nsd -h /var/db/nsd -s /sbin/nologin nsd \
 && install -d -o nsd -g nsd -m 0700 /var/db/nsd

VOLUME /var/db/nsd

EXPOSE 53
EXPOSE 53/udp

CMD ["nsd", "-d"]
