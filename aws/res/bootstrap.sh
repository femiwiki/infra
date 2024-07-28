#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

CNI_VERSION=1.4.0
NOMAD_VERSION=1.8.1
CONSUL_VERSION=1.19.1

#
# ec2-instance-connect 를 제일 먼저 설치
#
yum install -y ec2-instance-connect

#
# 기본 유틸리티들 설치
#
yum autoremove -y postfix
# - ripgrep: Disabled temporarily (https://github.com/femiwiki/femiwiki/issues/247)
# - dmidecode: required by Nomad (https://github.com/hashicorp/nomad/issues/19343#issuecomment-1845538511)
yum update -y
yum install -y \
  bash-completion \
  vim-enhanced \
  htop \
  tmux \
  git \
  amazon-cloudwatch-agent \
  jq \
  unzip \
  nc \
  dmidecode \
  dnsmasq \
  bind-utils \
;

#
# Install atop and sysstat
# Reference: https://repost.aws/knowledge-center/ec2-linux-configure-monitoring-tools
#
yum -y install sysstat atop
sed -i 's/^LOGINTERVAL=600.*/LOGINTERVAL=60/' /etc/sysconfig/atop
mkdir -v /etc/systemd/system/sysstat-collect.timer.d/
bash -c "sed -e 's|every 10 minutes|every 1 minute|g' -e '/^OnCalendar=/ s|/10$|/1|' /usr/lib/systemd/system/sysstat-collect.timer > /etc/systemd/system/sysstat-collect.timer.d/override.conf"
sed -i 's|^SADC_OPTIONS=.*|SADC_OPTIONS=" -S XALL"|' /etc/sysconfig/sysstat
sudo systemctl enable atop.service sysstat-collect.timer sysstat.service
sudo systemctl restart atop.service sysstat-collect.timer sysstat.service

#
# cloudwatch-agent 실행
#
cat <<'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/config.json
{
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ],
        "ignore_file_system_types": [
          "sysfs", "tmpfs", "devtmpfs", "overlay"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      }
    }
  }
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

#
# sudo 로 /usr/local/{bin,sbin} 안에 있는 커맨드를 실행할 수 있도록 설정
#
cat <<'EOF' > /etc/sudoers.d/10-sudo-path
Defaults secure_path=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
EOF

#
# 도커 설치
# Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker
#
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user
# 이후 로그아웃한 뒤 재로그인

#
# CNI 설치
# Required for Nomad 'bridge' network
#
case $(uname -p) in
  "x86_64")
    PROCESSOR="amd64"
    ;;
  "aarch64")
    PROCESSOR="arm64"
    ;;
esac
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-${PROCESSOR}-v${CNI_VERSION}.tgz"
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf cni-plugins.tgz
rm -f cni-plugins.tgz

#
# Nomad 설치
#
curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${PROCESSOR}.zip" \
    -Lo /home/ec2-user/nomad.zip
unzip /home/ec2-user/nomad.zip -d /usr/local/bin/
rm -f /home/ec2-user/nomad.zip
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad
mkdir -p /opt/nomad /etc/nomad.d

#
# Consul 설치
# Reference:
#   - https://github.com/hashicorp/terraform-aws-consul/blob/master/modules/install-consul/install-consul
#
curl "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${PROCESSOR}.zip" \
    -Lo /home/ec2-user/consul.zip
unzip /home/ec2-user/consul.zip -d /usr/local/bin/
rm /home/ec2-user/consul.zip
useradd consul
chown -R consul:consul /usr/local/bin/consul
chmod a+x /usr/local/bin/consul
# Enable consul autocompletion
consul -autocomplete-install
complete -C /usr/bin/consul consul

#
# dnsmasq 설정
# References:
# - https://learn.hashicorp.com/tutorials/consul/dns-forwarding#dnsmasq-setup
# - https://aws.amazon.com/premiumsupport/knowledge-center/dns-resolution-failures-ec2-linux
#
groupadd -r dnsmasq
useradd -r -g dnsmasq dnsmasq
echo 'server=/consul/127.0.0.1#8600' >> /etc/dnsmasq.d/10-consul
sudo systemctl restart dnsmasq.service
sudo systemctl enable dnsmasq.service

#
# TODO dns-forwarding (https://github.com/femiwiki/nomad/issues/8)
# References:
# - https://learn.hashicorp.com/tutorials/consul/dns-forwarding
# - https://aws.amazon.com/premiumsupport/knowledge-center/dns-resolution-failures-ec2-linux
#

#
# htoprc 생성
#
sudo -u ec2-user mkdir -p /home/ec2-user/.config/htop
sudo -u ec2-user tee /home/ec2-user/.config/htop/htoprc <<'EOF' >/dev/null
header_margin=1
hide_kernel_threads=1
hide_userland_threads=1
highlight_base_name=1
highlight_megabytes=1
tree_view=1
EOF

#
# Clone Femiwiki Nomad configurations and specifications repository
#
sudo -u ec2-user git clone https://github.com/femiwiki/nomad.git /home/ec2-user/nomad/
# Configure Nomad, Consul and systemd
/home/ec2-user/nomad/up

#
# README 생성
#
sudo -u ec2-user tee /home/ec2-user/README <<'EOF' >/dev/null
Nomad, Consul 관련 바이너리들

    /usr/local/bin/nomad              nomad 바이너리
    /usr/local/bin/consul             consul 바이너리

systemd 유닛 파일

    /etc/systemd/system/nomad.service
    /etc/systemd/system/consul.service

기타 관련 파일들 위치
    /etc/nomad.d                                     Nomad configuration
    /etc/consul.d                                    Consul configuration
    /opt/nomad                                       Nomad data directory
    /opt/consul                                      Consul data directory
    /opt/aws/amazon-cloudwatch-agent/bin/config.json CloudWatch Agent Configuration File
    /srv                                             Persistent EBS volume mount point for MySQL, certicates, cache and so on

그 외 인스턴스가 어떻게 세팅되었는지는 아래 repo 참고

    https://github.com/femiwiki/infra
EOF
