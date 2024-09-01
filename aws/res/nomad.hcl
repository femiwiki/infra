datacenter = "dc1"
data_dir   = "/opt/nomad"

acl {
  enabled = true
}

server {
  enabled = true
  # A value of 1 does not provide any fault tolerance and is not recommended for production use cases.
  bootstrap_expect = 1

  default_scheduler_config {
    # Memory oversubscription is opt-in in Nomad 1.1
    memory_oversubscription_enabled = true
  }
}

client {
  enabled = true
}

plugin "docker" {
  config {
    # CSI Node plugins must run as privileged Docker jobs
    allow_privileged = true

    volumes {
      enabled = true
    }
  }
}
