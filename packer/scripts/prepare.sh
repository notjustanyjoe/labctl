#!/usr/bin/env bash
set -euxo pipefail
#comment this out until packer sat registration is done
#dnf -y update --setopt=tsflags=nodocs || true
systemctl enable tmp.mount || true
