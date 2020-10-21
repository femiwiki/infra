#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

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
  jq \
  ripgrep \
  unzip \
  'https://www.atoptool.nl/download/atop-2.4.0-1.x86_64.rpm'

#
# yum-cron 설치
#
sed -i "s/update_cmd = default/update_cmd = minimal-security/" /etc/yum/yum-cron-hourly.conf
sed -i "s/update_cmd = default/update_cmd = minimal-security/" /etc/yum/yum-cron.conf
systemctl enable yum-cron

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
sudo amazon-linux-extras install -y docker=19.03.13
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
# 이후 로그아웃한 뒤 재로그인

# Clone Femiwiki Nomad configurations and specifications repository
sudo -u ec2-user git clone https://github.com/femiwiki/nomad.git /home/ec2-user/nomad/
GIT_REPO=/home/ec2-user/nomad

#
# Nomad 설치 및 설정
# Reference: https://learn.hashicorp.com/tutorials/nomad/production-deployment-guide-vm-with-consul
#
NOMAD_VERSION=0.12.5
curl "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" \
    -Lo /home/ec2-user/nomad_linux_amd64.zip
unzip /home/ec2-user/nomad_linux_amd64.zip -d /home/ec2-user
sudo mv /home/ec2-user/nomad /usr/local/bin/nomad
# Enable nomad autocompletion
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad
# Configure
sudo mkdir -p /opt/nomad /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo cp "${GIT_REPO}/production.hcl" /etc/nomad.d/nomad.hcl
sudo cp "${GIT_REPO}/systemd/nomad.service" /etc/systemd/system/nomad.service
sudo systemctl enable nomad
sudo systemctl start nomad

#
# Consul 설치 및 설정
# Reference: https://learn.hashicorp.com/tutorials/consul/deployment-guide
#
CONSUL_VERSION=1.8.4
curl "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    -Lo /home/ec2-user/consul_linux_amd64.zip
unzip /home/ec2-user/consul_linux_amd64.zip -d /home/ec2-user
sudo mv /home/ec2-user/consul /usr/local/bin/consul
# Enable consul autocompletion
consul -autocomplete-install
complete -C /usr/bin/consul consul
# Configure
sudo useradd -rd /etc/consul.d -s /bin/false consul
sudo mkdir -p /etc/consul.d /opt/consul
sudo chown -r consul:consul /etc/consul.d
sudo chown -r consul:consul /opt/consul
sudo cp "${GIT_REPO}/consul/consul.hcl" /etc/consul.d/consul.hcl
sudo chmod 640 /etc/consul.d/consul.hcl
consul validate /etc/consul.d/consul.hcl
sudo cp "${GIT_REPO}/systemd/consul.service" /etc/systemd/system/consul.service
sudo systemctl enable consul
sudo systemctl start consul

#
# Prepare stateful workloads with Container Storage Interface
#
cat <<'EOF' > /home/ec2-user/volume.hcl
# volume registration
type = "csi"
id = "mysql"
name = "mysql"
external_id = "PERSISTENT_DATA_VOLUME_ID"
access_mode = "single-node-writer"
attachment_mode = "file-system"
plugin_id = "aws-ebs0"
EOF

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
    /etc/nomad.d                                    Nomad configuration
    /etc/consul.d                                   Consul configuration
    /opt/nomad                                      Nomad data directory
    /opt/consul                                     Consul data directory

그 외 인스턴스가 어떻게 세팅되었는지는 아래 repo 참고

    https://github.com/femiwiki/infra
EOF

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
