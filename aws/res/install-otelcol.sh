#!/bin/bash
set -euo pipefail
set +x

# Both hosts are Graviton, so the arm64 builds; the hashes pin them
otelcol_version=__OTELCOL_VERSION__
otelcol_sha256=__OTELCOL_SHA256__
node_exporter_version=__NODE_EXPORTER_VERSION__
node_exporter_sha256=__NODE_EXPORTER_SHA256__

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

restart_node_exporter=0
restart_otelcol=0
reload_otelcol=0

install_unit() {
  local src=$1 dest=$2
  if cmp -s "$src" "$dest"; then
    return 1
  fi
  install -m 0644 "$src" "$dest"
  systemctl daemon-reload
}

# node_exporter, which Amazon Linux does not package
if [ "$(/usr/local/bin/node_exporter --version 2>/dev/null | awk 'NR == 1 { print $3 }')" != "$node_exporter_version" ]; then
  curl -sSfLo "$tmpdir/node_exporter.tar.gz" \
    "https://github.com/prometheus/node_exporter/releases/download/v$node_exporter_version/node_exporter-$node_exporter_version.linux-arm64.tar.gz"
  echo "$node_exporter_sha256  $tmpdir/node_exporter.tar.gz" | sha256sum -c --quiet
  tar -xzf "$tmpdir/node_exporter.tar.gz" -C "$tmpdir" --strip-components=1 \
    "node_exporter-$node_exporter_version.linux-arm64/node_exporter"
  install -m 0755 "$tmpdir/node_exporter" /usr/local/bin/node_exporter
  restart_node_exporter=1
fi

getent passwd node_exporter >/dev/null ||
  useradd --system --user-group --no-create-home --shell /sbin/nologin node_exporter

# The collectors and exclusions Alloy's built-in node_exporter had. Not on
# 9100, which the php-fpm probe takes in turns with 9101.
cat >"$tmpdir/node_exporter.service" <<'UNIT'
[Unit]
Description=Prometheus node_exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter \
  --web.listen-address=127.0.0.1:9110 \
  --no-collector.btrfs \
  --no-collector.infiniband \
  --no-collector.ipvs \
  --no-collector.xfs \
  --no-collector.zfs \
  --collector.filesystem.fs-types-exclude=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|tmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$$ \
  --collector.filesystem.mount-points-exclude=^/(dev|proc|run/credentials/.+|sys|var/lib/docker/.+)($$|/) \
  --collector.netclass.ignored-devices=^(veth.*|cali.*|[a-f0-9]{15})$$ \
  --collector.netdev.device-exclude=^(veth.*|cali.*|[a-f0-9]{15})$$
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
UNIT
if install_unit "$tmpdir/node_exporter.service" /etc/systemd/system/node_exporter.service; then
  restart_node_exporter=1
fi
systemctl enable --now node_exporter
if [ "$restart_node_exporter" -eq 1 ]; then
  systemctl restart node_exporter
fi

# The Collector (#1259). Its user and configuration come first, so the package
# keeps them (config|noreplace) instead of starting on its open default.
getent passwd otelcol-contrib >/dev/null ||
  useradd --system --user-group --no-create-home --shell /sbin/nologin otelcol-contrib
install -d -m 0750 -g otelcol-contrib /etc/otelcol-contrib

# docker_stats reads the Docker socket and journald the journal. Groups count
# from the next start.
for group in docker systemd-journal; do
  if getent group "$group" >/dev/null && ! id -nG otelcol-contrib | grep -qw "$group"; then
    usermod -a -G "$group" otelcol-contrib
    restart_otelcol=1
  fi
done

install_file() {
  local src=$1 dest=$2
  chmod 0640 "$src"
  chgrp otelcol-contrib "$src"
  if cmp -s "$src" "$dest"; then
    return
  fi
  mv -f "$src" "$dest"
  reload_otelcol=1
}

install_parameter() {
  local parameter=$1 dest=$2
  (
    umask 0077
    printf '%s' "$(aws ssm get-parameter \
      --region __REGION__ \
      --name "$parameter" \
      --with-decryption \
      --query Parameter.Value \
      --output text)" >"$tmpdir/parameter"
  )
  test -s "$tmpdir/parameter"
  install_file "$tmpdir/parameter" "$dest"
}

install_parameter /alloy/prometheus_password /etc/otelcol-contrib/prometheus.password
install_parameter /alloy/loki_password /etc/otelcol-contrib/loki.password

cat >"$tmpdir/config.yaml" <<'OTELCOL_CONFIG'
__CONFIG__
OTELCOL_CONFIG
install_file "$tmpdir/config.yaml" /etc/otelcol-contrib/config.yaml

# On a host without Docker, docker_stats is not configured; on one with it, the
# collector waits for the daemon rather than failing to start without it
mkdir -p /etc/systemd/system/otelcol-contrib.service.d
cat >"$tmpdir/override.conf" <<'UNIT'
[Unit]
After=docker.service

[Service]
# Profiles are still behind a feature gate
ExecStart=
ExecStart=/usr/bin/otelcol-contrib $OTELCOL_OPTIONS --feature-gates=+service.profilesSupport
RestartSec=10s
UNIT
if install_unit "$tmpdir/override.conf" /etc/systemd/system/otelcol-contrib.service.d/override.conf; then
  restart_otelcol=1
fi

if [ "$(rpm -q --qf '%{VERSION}' otelcol-contrib 2>/dev/null)" != "$otelcol_version" ]; then
  curl -sSfLo "$tmpdir/otelcol-contrib.rpm" \
    "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v$otelcol_version/otelcol-contrib_${otelcol_version}_linux_arm64.rpm"
  echo "$otelcol_sha256  $tmpdir/otelcol-contrib.rpm" | sha256sum -c --quiet
  dnf install -y "$tmpdir/otelcol-contrib.rpm"
  restart_otelcol=1
fi

systemctl enable --now otelcol-contrib
if [ "$restart_otelcol" -eq 1 ]; then
  systemctl restart otelcol-contrib
elif [ "$reload_otelcol" -eq 1 ]; then
  systemctl reload otelcol-contrib
fi

# The Collector took over everything Alloy sent (#1259)
if rpm -q alloy >/dev/null; then
  systemctl disable --now alloy
  dnf remove -y alloy
fi
