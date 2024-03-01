data "aws_ami" "amazon_linux_2_arm64" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    # You can get latest image name by executing (with AWS CLI v1)
    #   aws ec2 describe-images --filters "Name=name,Values=al2023-ami-minimal-*-*-*-arm64" --query 'sort_by(Images, &CreationDate)[::-1].[Name]'
    values = ["al2023-ami-minimal-*-*-*-arm64"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }
}
