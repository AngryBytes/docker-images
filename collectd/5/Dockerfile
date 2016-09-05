FROM debian:jessie
MAINTAINER Angry Bytes <info@angrybytes.com>

ENV COLLECTD_VERSION 5.5.2
ENV COLLECTD_SHA256 017f3a4062187e594d8ab6af685655fb82a8a942dc574668e68242bdb8ba820f

RUN buildDeps=" \
        curl \
        ca-certificates \
        bzip2 \
        build-essential \
        bison \
        flex \
        autotools-dev \
        libltdl-dev \
        pkg-config \
        librrd-dev \
        linux-libc-dev \
    " \
    runDeps=" \
        libltdl7 \
        librrd4 \
    " \
    && set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps $runDeps \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fSL "https://collectd.org/files/collectd-${COLLECTD_VERSION}.tar.bz2" -o "collectd-${COLLECTD_VERSION}.tar.bz2" \
    && echo "${COLLECTD_SHA256} *collectd-${COLLECTD_VERSION}.tar.bz2" | sha256sum -c - \
    && tar -xf "collectd-${COLLECTD_VERSION}.tar.bz2" \
    && rm "collectd-${COLLECTD_VERSION}.tar.bz2" \
    && ( \
        cd "collectd-${COLLECTD_VERSION}" \
        && ./configure \
            --prefix=/usr/local \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --disable-dependency-tracking \
            --disable-static \
        && make -j"$(nproc)" \
        && make install \
    ) \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
    && rm -fr "collectd-${COLLECTD_VERSION}"

CMD ["collectd", "-f"]
