datacenter = "dc1"
data_dir   = "/opt/consul"

server           = true
node_name        = "femiwiki"
bind_addr        = "{{GetInterfaceIP \"ens5\"}}"
bootstrap        = true
bootstrap_expect = 1
# Cloud Auto-join, but disabled because we have only one node now.
# https://www.consul.io/docs/install/cloud-auto-join#amazon-ec2
# retry_join = ["provider=aws tag_key=Name tag_value=femiwiki"]

ports {
  grpc = 8502
}

connect {
  enabled = true
}
