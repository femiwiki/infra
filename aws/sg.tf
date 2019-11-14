#
# 기본 SG
#
resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # NOTE: 기본 SG의 인그레스 규칙은 테라폼으로 관리하지 말고 수동으로 관리하자.
  # 이유는 비밀
  lifecycle {
    ignore_changes = [ingress]
  }
}

#
# 페미위키 서버용 SG
#
resource "aws_security_group" "femiwiki" {
  name        = "internal-server"
  description = "internal server"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "Femiwiki"
  }
}

resource "aws_security_group_rule" "femiwiki_ingress_http" {
  security_group_id = aws_security_group.femiwiki.id
  description       = "http"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "femiwiki_ingress_https" {
  security_group_id = aws_security_group.femiwiki.id
  description       = "https"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "femiwiki_egress" {
  security_group_id = aws_security_group.femiwiki.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
