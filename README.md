Femiwiki Infra
========
[![Github checks Status]][github checks link] [![Terraform Badge]][Terraform Cloud Link]

페미위키의 AWS 인프라가 정의되어있는 테라폼 코드입니다.

### Prerequisites

- Terraform
- [Terraform Cloud] 계정

### Instructions

```bash
# https://app.terraform.io/app/settings/tokens 에서 본인의 토큰을 확인한 뒤
# ~/.terraformrc 에 아래와 같이 테라폼 토큰 세팅
#
#     credentials "app.terraform.io" {
#       token = "xxxxxxxxxxxxxx.atlasv1.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#     }

terraform init
terraform plan
```

### `docker/` 적용하기

`docker/`는 Terraform Cloud를 쓰지 않습니다. 상태는 S3에 있고, 도커 데몬은 엣지 박스의 루프백에만 열려 있어서 SSM 터널로 붙습니다. PR을 열면 `docker plan`이 plan을 코멘트로 달고, 권한 있는 사람이 그 PR에 `terraform apply`라고 코멘트하면 `docker apply`가 그 plan을 적용합니다. 이미지 bump PR도 같은 흐름입니다.

적용이 끝나면 그 PR의 `## 업데이트` 절(이미지 bump PR이면 "Built from"에 적힌 docker-mediawiki PR들의 절까지)이 [페미위키:업데이트]의 그날 항목으로 올라갑니다. 각 줄은 `추가:`, `변경:`, `수정:` 중 하나로 시작하는 한국어 문장이고, 절이 없는 PR은 아무것도 올리지 않습니다. 봇 계정은 `docker` 환경의 `WIKI_BOT_USER`, `WIKI_BOT_PASSWORD` 시크릿입니다.

[페미위키:업데이트]: https://femiwiki.com/w/페미위키:업데이트

손으로 돌려야 할 때는 AWS CLI와 [Session Manager 플러그인]이 필요합니다.

```bash
# 터미널 1: 터널
aws ssm start-session \
  --target "$(aws ec2 describe-instances \
    --filters Name=tag:Name,Values=docker Name=instance-state-name,Values=running \
    --query 'Reservations[].Instances[].InstanceId' --output text)" \
  --document-name AWS-StartPortForwardingSession \
  --parameters portNumber=2376,localPortNumber=2376

# 터미널 2
terraform -chdir=docker init
terraform -chdir=docker plan
terraform -chdir=docker apply
```

[github checks status]: https://badgen.net/github/checks/femiwiki/infra
[github checks link]: https://github.com/femiwiki/infra/actions
[Terraform Badge]: https://badgen.net/badge/icon/terraform?label&icon=https://unpkg.com/badgen-icons@0.12.0/icons/terraform.svg
[Terraform Cloud Link]: https://app.terraform.io/app/femiwiki/workspaces
[Terraform Cloud]: https://app.terraform.io
[Session Manager 플러그인]: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
