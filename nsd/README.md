Available as: `angrybytes/nsd`

[NSD] is an authoritative only, high performance, simple and open source name
server.

This image is configured with the following directories:

    Zones directory   /etc/nsd
    Config file       /etc/nsd/nsd.conf
    Databases         /var/db/nsd
    PID file          /var/run/nsd.pid

Note that NSD defaults to running as user/group `nsd:nsd`. If you're running
NSD as a secondary, you may need to ensure the zonesdir is writable.

 [NSD]: http://www.nlnetlabs.nl/projects/nsd/
