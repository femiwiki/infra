datacenter = "dc1"
data_dir   = "/opt/nomad"

acl {
  enabled = true
}

server {
  enabled = true
  bootstrap_expect = 2

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
%{ if enable_consul == true }
consul {
  enabled = true
  address = "127.0.0.1:8500"

  service_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }

  task_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }
}
%{ endif }
