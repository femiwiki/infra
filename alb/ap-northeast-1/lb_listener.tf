resource "aws_lb_listener" "arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener--app--femiwiki-load-balancer--ebeed3504104bc38--d8e83ca24ba6c8e9" {
  default_action {
    order = "1"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }

    type = "redirect"
  }

  load_balancer_arn = "${aws_lb.femiwiki-load-balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_listener" "arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener--app--femiwiki-load-balancer--ebeed3504104bc38--71c0e97adaa91b48" {
  certificate_arn = "arn:aws:acm:ap-northeast-1:302617221463:certificate/6e39e4c9-6223-448b-afdd-79ef870a1fc0"

  default_action {
    order            = "2"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:302617221463:targetgroup/femiwiki-server/c4ab492257756dd9"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.femiwiki-load-balancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
}
