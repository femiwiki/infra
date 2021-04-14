#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

CNI_VERSION=0.9.1
NOMAD_VERSION=1.0.4

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
  nc \
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
          "/",
          "/srv"
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
# 시간대 설정
#
TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#
# persistent_data EBS 마운트
#
sudo mkdir -p /srv
echo "UUID=$(blkid -s UUID -o value /dev/xvdf)  /srv  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mount -a

#
# 스왑 메모리 생성
# 아마존 리눅스에서는 기본으로 XFS를 쓰는데, 이 경우 fallocate 명령어를 쓰지 못한다.
#
sudo dd if=/dev/zero of=/swapfile bs=256M count=6
sudo chmod 600 /swapfile
sudo mkswap /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
sudo swapon -a

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
# Configure Nomad and systemd
/home/ec2-user/nomad/up

#
# README 생성
#
sudo -u ec2-user tee /home/ec2-user/README <<'EOF' >/dev/null
바이너리들

    /usr/local/bin/nomad              nomad 바이너리

systemd 유닛 파일

    /etc/systemd/system/nomad.service

기타 관련 파일들 위치
    /etc/nomad.d                                     Nomad configuration
    /opt/nomad                                       Nomad data directory
    /opt/aws/amazon-cloudwatch-agent/bin/config.json CloudWatch Agent Configuration File
    /srv                                             Persistent EBS volume mount point for MySQL, certicates, cache and so on

그 외 인스턴스가 어떻게 세팅되었는지는 아래 repo 참고

    https://github.com/femiwiki/infra
EOF
