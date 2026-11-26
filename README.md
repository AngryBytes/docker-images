# Angry Bytes Docker images

This repository contains various public Docker images maintained by
Angry Bytes. See individual subdirectories for more details.

## Builds

`.github/workflows/build.yml` builds every image on a push to `main`, on pull
requests and when run by hand. Everything except pull requests publishes.

It also runs daily at 04:00 Amsterdam time. For each published
image, `.github/apt-upgrades.sh` runs `apt-get update` and a simulated
`apt-get upgrade` in it. The images that Debian has updates for are rebuilt, and
the build installs those updates with `apt-get upgrade`. Its result, a key over
the package versions after an upgrade, is passed as the build argument
`APT_UPGRADES`, so the apt steps only rerun when that key changes. Packages
pinned in a Dockerfile, like nginx, are held, so they only change with the
Dockerfile.
