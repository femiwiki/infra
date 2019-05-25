data "terraform_remote_state" "vpc" {
  backend = "local"

  config {
    path = "../../vpc/ap-northeast-1/terraform.tfstate"
  }
}
