resource "aws_lb" "femiwiki" {
  internal        = false
  ip_address_type = "ipv4"
  name            = "femiwiki-load-balancer"
  security_groups = [aws_security_group.loadbalancer.id]

  subnet_mapping {
    subnet_id = aws_default_subnet.default["a"].id
  }

  subnet_mapping {
    subnet_id = aws_default_subnet.default["d"].id
  }

  subnet_mapping {
    subnet_id = aws_default_subnet.default["c"].id
  }

  subnets = [
    aws_default_subnet.default["a"].id,
    aws_default_subnet.default["d"].id,
    aws_default_subnet.default["c"].id,
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.femiwiki.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.femiwiki.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.femiwiki_com.arn

  default_action {
    target_group_arn = aws_lb_target_group.femiwiki-server.arn
    type             = "forward"
  }
}

resource "aws_acm_certificate" "femiwiki_com" {
  domain_name = "femiwiki.com"
}

resource "aws_lb_listener_rule" "redirect_www" {
  listener_arn = aws_lb_listener.https.arn
  priority     = "2"

  action {
    type = "redirect"

    redirect {
      host        = "femiwiki.com"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "host-header"
    values = ["www.femiwiki.com"]
  }
}

resource "aws_lb_target_group" "femiwiki-server" {
  name        = "femiwiki-server"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_default_vpc.default.id

  health_check {
    healthy_threshold   = "5"
    matcher             = "200"
    path                = "/index.php"
    unhealthy_threshold = "2"
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
}

resource "aws_lb_target_group" "femiwiki-restbase" {
  name        = "femiwiki-restbase"
  port        = "7231"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_default_vpc.default.id

  health_check {
    healthy_threshold   = "5"
    matcher             = "200"
    path                = "/"
    unhealthy_threshold = "2"
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
}
