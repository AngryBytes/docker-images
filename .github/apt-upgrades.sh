#!/usr/bin/env bash
# Prints "<key> <updates>" for a published image: a key over its Debian package versions
# after an upgrade, and how many packages an upgrade would update. Held (pinned) packages
# don't count. The key only changes when an upgrade would install different versions, so it
# can invalidate the build's cached apt step.
#
#   .github/apt-upgrades.sh angrybytes/abc-base:8.5
set -euo pipefail

image="${1:?usage: $0 <image>}"

output="$(
  docker run --rm --pull always --platform linux/amd64 --user 0 --entrypoint sh "$image" -c '
    apt-get update -qq >/dev/null
    dpkg-query -W -f "\${Package}=\${Version}\n"
    echo ---
    apt-get -s upgrade
  '
)"

# Installed versions, replaced by the version a simulated upgrade would install
# ("Inst <name> [<installed>] (<new> <suite> [<arch>])").
packages="$(awk '
  $0 == "---" { upgrade = 1; next }
  !upgrade { split($0, kv, "="); version[kv[1]] = substr($0, length(kv[1]) + 2); next }
  /^Inst / { new = $0; sub(/^[^(]*\(/, "", new); sub(/ .*/, "", new); version[$2] = new; updates++ }
  END {
    for (name in version) print name "=" version[name]
    print updates + 0 > "/dev/stderr"
  }' <<<"$output" 2>"${TMPDIR:-/tmp}/apt-upgrades.$$" | sort)"
updates="$(cat "${TMPDIR:-/tmp}/apt-upgrades.$$")"
rm -f "${TMPDIR:-/tmp}/apt-upgrades.$$"

echo "$(sha256sum <<<"$packages" | cut -c1-16) $updates"
