#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

CNI_VERSION=0.9.1
NOMAD_VERSION=1.1.2
CONSUL_VERSION=1.10.0

#
# ec2-instance-connect 를 제일 먼저 설치
#
yum install -y ec2-instance-connect

#
# 기본 유틸리티들 설치
#
yum autoremove -y postfix
# Disabled temporarily, See https://github.com/femiwiki/femiwiki/issues/247
# curl -Lo /etc/yum.repos.d/carlwgeorge-ripgrep-epel-7.repo \
#   'https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo'
yum update -y
yum install -y \
  bash-completion \
  vim-enhanced \
  htop \
  tmux \
  git \
  yum-cron \
  amazon-cloudwatch-agent \
  jq \
  unzip \
  dnsmasq \
  bind-utils
  # Disabled temporarily, See https://github.com/femiwiki/femiwiki/issues/247
  # ripgrep

#
# Install atop and sysstat
# Reference: https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-configure-monitoring-tools/#Amazon_Linux_2
#
amazon-linux-extras install -y epel
sudo yum -y install sysstat atop --enablerepo=epel
sudo sed -i 's/^LOGINTERVAL=600.*/LOGINTERVAL=60/' /etc/sysconfig/atop
sudo sed -i -e 's|*/10|*/1|' -e 's|every 10 minutes|every 1 minute|' /etc/cron.d/sysstat
sudo systemctl enable atop.service crond.service sysstat.service
sudo systemctl restart atop.service crond.service sysstat.service

#
# yum-cron 설치
#
sed -i "s/update_cmd = default/update_cmd = minimal-security/" /etc/yum/yum-cron-hourly.conf
sed -i "s/update_cmd = default/update_cmd = minimal-security/" /etc/yum/yum-cron.conf
sed -i "s/apply_updates = no/apply_updates = yes/" /etc/yum/yum-cron.conf
sed -i "s~^exec /usr/sbin/yum-cron~exec /usr/bin/nice -n 19 /usr/sbin/yum-cron~" /etc/cron.hourly/0yum-hourly.cron
sed -i "s~^exec /usr/sbin/yum-cron~exec /usr/bin/nice -n 19 /usr/sbin/yum-cron~" /etc/cron.daily/0yum-daily.cron
systemctl enable yum-cron

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
          "/",
          "/opt/nomad/client/csi/node/aws-ebs0/staging/mysql/rw-file-system-single-node-writer"
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
amazon-linux-extras install -y docker
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
rm cni-plugins.tgz

#
# Nomad 설치
#
curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${PROCESSOR}.zip" \
    -Lo /home/ec2-user/nomad.zip
unzip /home/ec2-user/nomad.zip -d /usr/local/bin/
rm /home/ec2-user/nomad.zip
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
/home/ec2-user/nomad/up-consul-test

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
