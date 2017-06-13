#!/bin/sh
set -e

nsd

exec inotifyd - "${ZONESDIR:-/etc/nsd}":wymd | \
  while read; do
    while read -t 1; do true; done
    kill -SIGHUP $(cat "${PIDFILE:-/var/run/nsd.pid}")
  done
