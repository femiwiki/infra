resource "aws_eip" "web" {
  for_each = { for key, host in local.app_host_list.hosts : key => host if try(host.eip, false) }

  domain = "vpc"

  tags = { Name = "femiwiki.com" }
}
