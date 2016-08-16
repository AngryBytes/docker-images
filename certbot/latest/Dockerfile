FROM python:2.7
MAINTAINER Angry Bytes <info@angrybytes.com>

# Install apt requirements.
RUN set -xe \
 && apt-get update \
 && apt-get install --no-install-recommends -y dialog \
 && rm -rf /var/lib/apt/lists/*

# Install pip requirements, extracted from certbot-auto.
ADD letsencrypt-auto-requirements.txt /usr/src
RUN pip install --no-cache-dir --require-hashes \
        -r /usr/src/letsencrypt-auto-requirements.txt

ENTRYPOINT ["certbot"]
