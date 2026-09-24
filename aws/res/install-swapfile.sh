#!/bin/bash
set -euo pipefail

SIZE_MIB=__SIZE_MIB__
FILE=/swapfile

if [ ! -f "$FILE" ]; then
  fallocate -l "${SIZE_MIB}M" "$FILE"
  chmod 0600 "$FILE"
  mkswap "$FILE"
fi

swapon --show=NAME --noheadings | grep -qx "$FILE" || swapon "$FILE"

grep -qF "$FILE" /etc/fstab || printf '%s none swap sw,nofail 0 0\n' "$FILE" >>/etc/fstab

# Only under real pressure, and only as a floor under a container swap; the file
# sits on EBS, so reading back from it is slow.
sysctl -q vm.swappiness=1
grep -qs '^vm.swappiness' /etc/sysctl.d/99-swapfile.conf ||
  printf 'vm.swappiness = 1\n' >/etc/sysctl.d/99-swapfile.conf
