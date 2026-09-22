#!/bin/bash
set -euo pipefail
set +x
umask 0077

changed=0
tmpdir=$(mktemp -d /etc/alloy/.install-XXXXXX)
trap 'rm -rf "$tmpdir"' EXIT

install_file() {
  local src=$1 dest=$2
  chmod 0640 "$src"
  chgrp alloy "$src"
  if cmp -s "$src" "$dest"; then
    return
  fi
  mv -f "$src" "$dest"
  changed=1
}

install_parameter() {
  local parameter=$1 dest=$2 src="$tmpdir/parameter"
  printf '%s' "$(aws ssm get-parameter \
    --region __REGION__ \
    --name "$parameter" \
    --with-decryption \
    --query Parameter.Value \
    --output text)" >"$src"
  test -s "$src"
  install_file "$src" "$dest"
}

install_parameter /alloy/prometheus_password /etc/alloy/prometheus.password
install_parameter /alloy/loki_password /etc/alloy/loki.password

cat >"$tmpdir/config.alloy" <<'ALLOY_CONFIG'
__CONFIG__
ALLOY_CONFIG
install_file "$tmpdir/config.alloy" /etc/alloy/config.alloy

if [ "$changed" -eq 1 ]; then
  systemctl reload-or-restart alloy
fi
