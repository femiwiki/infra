#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

CNI_VERSION=0.9.1
NOMAD_VERSION=1.0.4
CONSUL_VERSION=1.9.4

#
# ec2-instance-connect 를 제일 먼저 설치
#
yum install -y ec2-instance-connect

#
# 기본 유틸리티들 설치
#
yum autoremove -y postfix
curl -Lo /etc/yum.repos.d/carlwgeorge-ripgrep-epel-7.repo \
  'https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo'
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
  ripgrep \
  unzip \
  dnsmasq \
  nc \
  bind-utils \
  'https://www.atoptool.nl/download/atop-2.4.0-1.x86_64.rpm'

#
# yum-cron 설치
#
sed -i "s/update_cmd = default/update_cmd = minimal-security/" /etc/yum/yum-cron-hourly.conf
sed -i "s/update_cmd = default/update_cmd = minimal-security/" /etc/yum/yum-cron.conf
systemctl enable yum-cron

#
# cloudwatch-agent 실행
#
cat <<'EOF' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "*"
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
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

#
# sudo 로 /usr/local/{bin,sbin} 안에 있는 커맨드를 실행할 수 있도록 설정
#
cat <<'EOF' > /etc/sudoers.d/10-sudo-path
Defaults secure_path=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
EOF

#
# persistent_data EBS 마운트
#
sudo mkdir -p /srv
echo "UUID=$(blkid -s UUID -o value /dev/xvdf)  /srv  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mount -a

#
# 도커 설치
# Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker
# You can see supported docker versions with:
#   docker run --rm amazonlinux:2.0.20201218.1 amazon-linux-extras list | grep -A 1 docker
#
amazon-linux-extras install -y docker=18.09.9
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user
# 이후 로그아웃한 뒤 재로그인

#
# CNI 설치
#
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz"
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf cni-plugins.tgz
rm cni-plugins.tgz

#
# Nomad 설치
#
curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" \
    -Lo /home/ec2-user/nomad_linux_amd64.zip
unzip /home/ec2-user/nomad_linux_amd64.zip -d /usr/local/bin/
rm /home/ec2-user/nomad_linux_amd64.zip
# Enable nomad autocompletion
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad

#
# Consul 설치
# Reference:
#   - https://github.com/hashicorp/terraform-aws-consul/blob/master/modules/install-consul/install-consul
#
curl "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    -Lo /home/ec2-user/consul_linux_amd64.zip
unzip /home/ec2-user/consul_linux_amd64.zip -d /usr/local/bin/
rm /home/ec2-user/consul_linux_amd64.zip
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
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo 'server=/consul/127.0.0.1#8600' >> /etc/dnsmasq.d/10-consul
sudo systemctl restart dnsmasq.service
sudo systemctl enable dnsmasq.service

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

그 외 인스턴스가 어떻게 세팅되었는지는 아래 repo 참고

    https://github.com/femiwiki/infra
EOF
