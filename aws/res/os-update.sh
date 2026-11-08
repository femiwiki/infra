#!/bin/bash
set -euo pipefail

# Past MemoryHigh dnf is slowed and swapped out rather than taking memory from
# the containers
run() {
  systemd-run --wait --pipe --quiet --collect \
    -p MemoryHigh=__MEMORY_HIGH_MIB__M -p MemoryMax=__MEMORY_MAX_MIB__M \
    -p CPUWeight=20 -p IOWeight=20 \
    "$@"
}

# Live patches keep the running kernel patched without a reboot, for three
# months after its release
if ! rpm -q kpatch-dnf kpatch-runtime >/dev/null; then
  run dnf install -y -q kpatch-dnf kpatch-runtime
  run dnf kernel-livepatch -y auto
fi
systemctl enable --now kpatch.service

# The host's own release gets no new packages. Upgrading the SSM agent would
# restart it under this command.
run dnf upgrade -y -q --releasever=latest --exclude=amazon-ssm-agent

kpatch list
