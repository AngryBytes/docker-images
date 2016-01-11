Available as: `angrybytes/collectd`

A fairly simple collectd installation. Basically what you get when you build
on a clean Debian installation, but with RRD support.

Our purpose for this image is a central collectd server that only receives
from other systems, and writes to RRD files.

Builtin defaults:

    Config file       /etc/collectd.conf
    PID file          /var/run/collectd.pid
    Plugin directory  /usr/local/lib/collectd
    Data directory    /var/lib/collectd

Use a volume to provide custom configuration, e.g.:

    docker run
        -v /srv/collectd/collectd.conf:/etc/collectd.conf:ro \
        angrybytes/collectd:5

(Or alternatively, derive from the image.)
