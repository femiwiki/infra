resource "docker_container" "proxysql" {
  name         = "proxysql"
  log_driver   = "local"
  image        = "proxysql/proxysql:2.7.3"
  network_mode = "host"
  restart      = "always"
  memory       = 128
  memory_swap  = 256

  mounts {
    type      = "bind"
    source    = "/etc/femiwiki/proxysql.cnf"
    target    = "/etc/proxysql.cnf"
    read_only = true
  }

  mounts {
    type      = "volume"
    source    = docker_volume.proxysql.id
    target    = "/var/lib/proxysql"
    read_only = false
  }

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }

  labels {
    label = "autoheal"
    value = "false"
  }
}
