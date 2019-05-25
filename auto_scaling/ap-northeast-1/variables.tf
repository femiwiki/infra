data "terraform_remote_state" "sg" {
  backend = "local"

  config {
    path = "../../sg/ap-northeast-1/terraform.tfstate"
  }
}

data "terraform_remote_state" "subnet" {
  backend = "local"

  config {
    path = "../../subnet/ap-northeast-1/terraform.tfstate"
  }
}
