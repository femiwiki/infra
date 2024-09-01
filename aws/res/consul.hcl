datacenter = "dc1"
data_dir   = "/opt/consul"

acl {
  enabled = true
}

server           = true
node_name        = "femiwiki"
bind_addr        = "{{GetInterfaceIP \"ens5\"}}"
bootstrap        = true
bootstrap_expect = 1
# Cloud Auto-join
# https://www.consul.io/docs/install/cloud-auto-join#amazon-ec2
retry_join = ["provider=aws tag_key=consul-cloud-auto-join tag_value=true"]

ports {
  grpc = 8502
}

connect {
  enabled = true
}
