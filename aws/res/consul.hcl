datacenter = "dc1"
data_dir   = "/opt/consul"

acl {
  enabled = true
}

server           = true
node_name        = "femiwiki"
advertise_addr   = "IP_ADDRESS"
bind_addr        = "0.0.0.0"
client_addr      = "0.0.0.0"
bootstrap        = true
bootstrap_expect = 1
# Cloud Auto-join
# https://www.consul.io/docs/install/cloud-auto-join#amazon-ec2
# https://github.com/hashicorp/nomad/blob/v1.8.4/terraform/aws/modules/hashistack/hashistack.tf#L41-L43
retry_join = ["provider=aws tag_key=ConsulAutoJoin tag_value=auto-join"]

ports {
  grpc = 8502
}

connect {
  enabled = true
}
