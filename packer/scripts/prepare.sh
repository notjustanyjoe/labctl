#!/usr/bin/env bash
set -euxo pipefail
dnf -y update --setopt=tsflags=nodocs || true
systemctl enable tmp.mount || true
