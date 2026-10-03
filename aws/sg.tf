#
# Default SG
#
resource "aws_default_security_group" "default" {
  region = local.tokyo_region
  vpc_id = aws_default_vpc.default.id

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # NOTE: Do not manage the default SG's ingress rules with Terraform; manage them manually.
  # The reason is a secret.
  lifecycle {
    ignore_changes = [ingress]
  }
}

# See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-setup-security-group
resource "aws_security_group_rule" "default_instance_connect_browser_based_client" {
  region            = local.tokyo_region
  security_group_id = aws_default_security_group.default.id
  description       = "EC2 Instance Connect Browser-based client"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["3.112.23.0/29"]
}
