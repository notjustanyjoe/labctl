#!/usr/bin/env bash
set -euxo pipefail
rm -rf /tmp/* /var/cache/{dnf,yum}/* || true
rm -f /etc/ssh/ssh_host_* || true
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY
sync; sync
