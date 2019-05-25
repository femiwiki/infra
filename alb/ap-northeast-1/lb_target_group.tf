resource "aws_lb_target_group" "femiwiki-restbase" {
  deregistration_delay = "300"

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  name       = "femiwiki-restbase"
  port       = "7231"
  protocol   = "HTTP"
  slow_start = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = false
    type            = "lb_cookie"
  }

  tags        {}
  target_type = "instance"
  vpc_id      = "${data.terraform_remote_state.vpc.aws_vpc_vpc-a4749ac0_id}"
}

resource "aws_lb_target_group" "femiwiki-server" {
  deregistration_delay = "300"

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200"
    path                = "/w/%ED%8E%98%EB%AF%B8%EC%9C%84%ED%82%A4:%EB%8C%80%EB%AC%B8"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  name       = "femiwiki-server"
  port       = "80"
  protocol   = "HTTP"
  slow_start = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = false
    type            = "lb_cookie"
  }

  tags        {}
  target_type = "instance"
  vpc_id      = "${data.terraform_remote_state.vpc.aws_vpc_vpc-a4749ac0_id}"
}
