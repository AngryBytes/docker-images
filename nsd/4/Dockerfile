FROM debian:jessie
MAINTAINER Angry Bytes <info@angrybytes.com>

ENV NSD_VERSION 4.1.12
ENV NSD_SHA256 fd1979dff1fba55310fd4f439dc9f3f4701d435c0ec4fb9af533e12c7f27d5de

RUN buildDeps=" \
        curl \
        gcc \
        make \
        libssl-dev \
        libevent-dev \
    " \
    runDeps=" \
        libssl1.0.0 \
        libevent-2.0-5 \
    " \
    && set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps $runDeps \
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
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
    && rm -fr "nsd-${NSD_VERSION}" \
    && useradd -r -d /etc/nsd -s /sbin/nologin -c "nsd daemon account" nsd \
    && install -d -o nsd -g nsd -m 0700 /var/db/nsd

VOLUME /var/db/nsd

EXPOSE 53
EXPOSE 53/udp

CMD ["nsd", "-d"]
