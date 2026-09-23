Femiwiki Infra
========
[![Github checks Status]][github checks link] [![Terraform Badge]][Terraform Cloud Link]

페미위키의 AWS 인프라가 정의되어있는 테라폼 코드입니다.

### Prerequisites

- Terraform (`aws/`, `github/`), [OpenTofu] (`docker/`, `grafana/`)
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

`docker/`는 Terraform Cloud를 쓰지 않습니다. 상태는 S3에 있고, 도커 데몬은 엣지 박스의 루프백에만 열려 있어서 SSM 터널로 붙습니다. PR을 열면 `.github/workflows/tofu.yaml`이 plan을 코멘트로 달고, 권한 있는 사람이 그 PR에 `tofu apply`라고 코멘트하면 같은 워크플로가 PR이 바꾼 워크스페이스의 plan을 적용합니다. 이미지 bump PR도 같은 흐름입니다.

`tofu apply` 코멘트에 붙는 👍은 [dflook/tofu-apply]가 시작하면서 붙이는 것이고, 결과와는 상관없습니다. 결과는 plan 코멘트 맨 아래 상태 줄에 나옵니다. 🟠는 적용하는 중, ✅는 적용했음, ❌는 적용하지 않았거나 실패했음입니다.

머지는 그 다음입니다. `docker plan is empty`와 `grafana plan is empty`가 필수 검사라서, plan이 비어 있지 않은 PR은 머지되지 않습니다. apply가 끝나면 그 PR의 plan을 다시 돌려 검사를 갱신하므로, 적용하고 나면 따로 할 일은 없습니다. `grafana/`도 같습니다.

### 워크스페이스 추가하기

plan과 apply는 모든 워크스페이스가 `tofu.yaml` 하나를 같이 씁니다. 새 워크스페이스를 만들 때 필요한 것은 이렇습니다.

1. `<이름>/` 디렉터리와 S3 백엔드 키 `<이름>/terraform.tfstate`
2. `aws/iam.tf`에 상태 버킷을 읽는 `infra-<이름>` 역할. 신뢰 정책의 `sub`는 `pull_request`와 `environment:<이름>` 둘입니다
3. 같은 이름의 GitHub 환경
4. `tofu.yaml`의 `workflow_dispatch` 선택지(`&workspaces`)에 `<이름>`. plan의 `matrix`가 이 목록을 같이 쓰고, apply는 3번의 환경이 있는 디렉터리만 적용합니다. Discord 웹후크의 `case()`에도 더하고, 변수가 있으면 `TF_VAR_*`도 더합니다
5. 4번이 머지된 뒤에 `github/repo.tf`의 필수 검사에 `<이름> plan is empty`를 더합니다

5번의 순서는 지켜야 합니다. `enforce_admins`가 켜져 있어서, 아직 존재하지 않는 검사를 필수로 걸면 그것을 되돌리는 PR도 머지되지 않습니다.

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
tofu -chdir=docker init
tofu -chdir=docker plan
tofu -chdir=docker apply
```

[github checks status]: https://badgen.net/github/checks/femiwiki/infra
[github checks link]: https://github.com/femiwiki/infra/actions
[Terraform Badge]: https://badgen.net/badge/icon/terraform?label&icon=https://unpkg.com/badgen-icons@0.12.0/icons/terraform.svg
[Terraform Cloud Link]: https://app.terraform.io/app/femiwiki/workspaces
[Terraform Cloud]: https://app.terraform.io
[Session Manager 플러그인]: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
[OpenTofu]: https://opentofu.org
[dflook/tofu-apply]: https://github.com/dflook/terraform-github-actions/tree/main/tofu-apply
