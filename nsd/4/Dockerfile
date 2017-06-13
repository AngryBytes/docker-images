FROM alpine

ENV NSD_VERSION 4.1.16
ENV NSD_SHA256 7f8367ad23cc5cddffa885e7e2f549123c8b4123db9726df41d99f255d6baab2

RUN set -x \
 && apk update \
 && apk add \
        openssl \
        libevent \
 && apk add --virtual .build-deps \
        curl \
        gcc \
        make \
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
     && make -j"$(nproc)" \
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
