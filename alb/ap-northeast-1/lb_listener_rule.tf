resource "aws_lb_listener_rule" "arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener-rule--app--femiwiki-load-balancer--ebeed3504104bc38--71c0e97adaa91b48--4511a96cfa387238" {
  action {
    order            = "0"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:302617221463:targetgroup/femiwiki-server/c4ab492257756dd9"
    type             = "forward"
  }

  listener_arn = "${aws_lb_listener.arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener--app--femiwiki-load-balancer--ebeed3504104bc38--71c0e97adaa91b48.arn}"
  priority     = "99999"
}

resource "aws_lb_listener_rule" "arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener-rule--app--femiwiki-load-balancer--ebeed3504104bc38--71c0e97adaa91b48--80857c688f036551" {
  action {
    order = "1"

    redirect {
      host        = "femiwiki.com"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }

    type = "redirect"
  }

  condition {
    field  = "host-header"
    values = ["www.femiwiki.com"]
  }

  listener_arn = "${aws_lb_listener.arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener--app--femiwiki-load-balancer--ebeed3504104bc38--71c0e97adaa91b48.arn}"
  priority     = "2"
}

resource "aws_lb_listener_rule" "arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener-rule--app--femiwiki-load-balancer--ebeed3504104bc38--d8e83ca24ba6c8e9--5c20be25cabfb4c8" {
  action {
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

  listener_arn = "${aws_lb_listener.arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--listener--app--femiwiki-load-balancer--ebeed3504104bc38--d8e83ca24ba6c8e9.arn}"
  priority     = "99999"
}
