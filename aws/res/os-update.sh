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

# The host's own release gets no new packages. Upgrading the SSM agent would
# restart it under this command.
run dnf upgrade -y -q --releasever=latest --exclude=amazon-ssm-agent
