#!/bin/bash
set -euo pipefail

# Applies and the database swap reach the daemon's socket through ssh over SSM,
# so the daemon listens on nothing else
grep -qE '^OPTIONS=.* -H tcp://' /etc/sysconfig/docker || exit 0

# Without live-restore a restart would stop every container
[ "$(docker info --format '{{.LiveRestoreEnabled}}')" = true ] ||
  { echo "live-restore is off, so the daemon is left as it is" >&2; exit 1; }

sed -i -E '/^OPTIONS=/ s? -H tcp://[^ "]+??' /etc/sysconfig/docker
systemctl restart docker
