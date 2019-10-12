Femiwiki Infra
========
[![Terraform Badge]][Terraform Cloud Link]

페미위키의 AWS 인프라가 정의되어있는 테라폼 코드입니다.

### Prerequisites
- Terraform 0.12
- [Terraform Cloud] 계정
- AWS 크레덴셜

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

### TODOs
- [ ] 인스턴스 프로필 (ec2.tf 에 인스턴스 프로필 ARN 하드코딩되어있음)
- [ ] SES
- [ ] EC2
- [ ] ALB
- [ ] IAM
- [ ] Route53

[Terraform Badge]: https://badgen.net/badge/icon/terraform?label&icon=https://unpkg.com/badgen-icons@0.12.0/icons/terraform.svg
[Terraform Cloud Link]: https://app.terraform.io/app/femiwiki/workspaces/infra
[Terraform Cloud]: https://app.terraform.io
