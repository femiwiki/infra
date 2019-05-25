data "terraform_remote_state" "subnet" {
  backend = "local"

  config {
    path = "../../subnet/ap-northeast-1/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config {
    path = "../../vpc/ap-northeast-1/terraform.tfstate"
  }
}
