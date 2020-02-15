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
# k3s states EBS 마운트
#
sudo mkdir -p /srv
echo "UUID=$(blkid -s UUID -o value /dev/xvdf)  /srv  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mount -a

#
# k3s 설치
#
curl -sfL https://get.k3s.io |
  INSTALL_K3S_VERSION='v1.17.4+k3s1' \
  INSTALL_K3S_EXEC='server --write-kubeconfig-mode 644' \
  sh
# Reference: https://rancher.com/docs/k3s/latest/en/installation/install-options

# Enable kubectl autocompletion
kubectl completion bash > /etc/bash_completion.d/kubectl

#
# README 생성
#
sudo -u ec2-user tee /home/ec2-user/README <<'EOF' >/dev/null
k3s 관련 바이너리들

    /usr/local/bin/k3s                k3s 바이너리
    /usr/local/bin/k3s-killall.sh
    /usr/local/bin/k3s-uninstall.sh

그 외 커맨드라인 유틸리티들

    /usr/local/bin/kubectl            kubernetes CLI
    /usr/local/bin/ctr                containerd CLI
    /usr/local/bin/crictl             CRI 클라이언트

k3s systemd 유닛 파일

    /etc/systemd/system/k3s.service
    /etc/systemd/system/k3s.service.env

k3s 관련 파일들 위치

    /var/lib/rancher/k3s                            k3s가 동적으로 생성한 데이터들
    /etc/rancher/k3s/k3s.yaml                       kubeconfig 파일

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

#
# kubectl을 k로 alias
#
sudo -u ec2-user tee -a /home/ec2-user/.bashrc <<'EOF' >/dev/null
alias k=kubectl
complete -F __start_kubectl k
EOF
