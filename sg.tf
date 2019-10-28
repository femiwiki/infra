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
# DB용 SG
#
resource "aws_security_group" "db" {
  name        = "internal-mysql"
  description = "internal mysql"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "mysql+memcached"
  }
}

resource "aws_security_group_rule" "db_ingress_mysql" {
  security_group_id = aws_security_group.db.id
  description       = "MySQL from Mediawiki"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.mediawiki.id
}

resource "aws_security_group_rule" "db_ingress_memcached" {
  security_group_id = aws_security_group.db.id
  description       = "memcached from Mediawiki"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 11211
  to_port                  = 11211
  source_security_group_id = aws_security_group.mediawiki.id
}

resource "aws_security_group_rule" "db_ingress_cassandra" {
  security_group_id = aws_security_group.db.id
  description       = "Cassandra from Mediawiki"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9042
  to_port                  = 9042
  source_security_group_id = aws_security_group.mediawiki.id
}

resource "aws_security_group_rule" "db_egress" {
  security_group_id = aws_security_group.db.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}


#
# 미디어위키 서버의 SG
#
resource "aws_security_group" "mediawiki" {
  name        = "internal-http-server"
  description = "internal http server"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "mediawiki"
  }
}

resource "aws_security_group_rule" "mediawiki_ingress_http" {
  security_group_id = aws_security_group.mediawiki.id
  description       = "http from load balancer"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "mediawiki_ingress_https" {
  security_group_id = aws_security_group.mediawiki.id
  description       = "https from load balancer"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "mediawiki_egress" {
  security_group_id = aws_security_group.mediawiki.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}


#
# 로드밸런서의 SG
#
resource "aws_security_group" "loadbalancer" {
  name        = "public http server"
  description = "public http server"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "loadbalancer"
  }
}

resource "aws_security_group_rule" "loadbalancer_ingress_http" {
  security_group_id = aws_security_group.loadbalancer.id

  type             = "ingress"
  protocol         = "tcp"
  from_port        = 80
  to_port          = 80
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "loadbalancer_ingress_https" {
  security_group_id = aws_security_group.loadbalancer.id

  type             = "ingress"
  protocol         = "tcp"
  from_port        = 443
  to_port          = 443
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "loadbalancer_egress" {
  security_group_id = aws_security_group.loadbalancer.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
