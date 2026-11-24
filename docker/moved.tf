# One container of each per key of app-hosts.json; today's host is app-1 (femiwiki/femiwiki#577)

moved {
  from = docker_container.http
  to   = docker_container.http["app-1"]
}

moved {
  from = docker_container.fastcgi
  to   = docker_container.fastcgi["app-1"]
}

moved {
  from = docker_container.jobrunner
  to   = docker_container.jobrunner["app-1"]
}

moved {
  from = docker_container.proxysql[0]
  to   = docker_container.proxysql["app-1"]
}

moved {
  from = docker_container.memcached
  to   = docker_container.memcached["app-1"]
}

moved {
  from = docker_container.autoheal
  to   = docker_container.autoheal["app-1"]
}
