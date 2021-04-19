# TODO: 없앨 예정
data "aws_ami" "femiwiki_base" {
  most_recent = true
  name_regex  = "^femiwiki-base \\d{4}-\\d{2}-\\d{2} \\d{2}_\\d{2}$"
  owners      = ["self"]
}

data "aws_ami" "amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-minimal-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }

  # 이 AMI로 고정함
  # You can get latest image name by executing (with AWS CLI v1)
  #   aws ec2 describe-images --filters "Name=name,Values=amzn2-ami-minimal-hvm-2.0.*-x86_64-ebs" --query 'sort_by(Images, &CreationDate)[::-1].[Name]'
  name_regex = "^amzn2-ami-minimal-hvm-2.0.20201218.1-x86_64-ebs$"
}

data "aws_ami" "amazon_linux_2_arm64" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    # aws ec2 describe-images --filters "Name=name,Values=amzn2-ami-minimal-hvm-2.0.*-arm64-ebs" --query 'sort_by(Images, &CreationDate)[::-1].[Name]'
    values = ["amzn2-ami-minimal-hvm-2.0.*-arm64-ebs"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }
}
