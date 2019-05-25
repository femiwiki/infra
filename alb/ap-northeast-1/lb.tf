resource "aws_lb" "femiwiki-load-balancer" {
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = "60"
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "femiwiki-load-balancer"
  security_groups            = ["sg-07644ee8da7b994d2"]

  subnet_mapping {
    subnet_id = "subnet-e5d929bd"
  }

  subnet_mapping {
    subnet_id = "subnet-2581d80d"
  }

  subnet_mapping {
    subnet_id = "subnet-9da70beb"
  }

  subnets = ["${data.terraform_remote_state.subnet.aws_subnet_subnet-9da70beb_id}", "${data.terraform_remote_state.subnet.aws_subnet_subnet-e5d929bd_id}", "${data.terraform_remote_state.subnet.aws_subnet_subnet-2581d80d_id}"]
  tags    {}
}
