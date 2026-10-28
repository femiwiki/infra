locals {
  # The ProxySQL switch rolls the wiki like a deploy, so it moves the generation too
  fastcgi_generation = 169 + (var.proxysql_enabled ? 1 : 0)
  # The generation whose fastcgi runs update.php as it starts, set with an image
  # that changes the schema; it lapses once the generation moves on
  schema_update_generation = 164

  # To the OpenTelemetry Collector on the host, which ships them to Loki. Async,
  # so a container still starts while the Collector is down.
  log_opts = {
    "fluentd-address" = "127.0.0.1:24224"
    "fluentd-async"   = "true"
  }

  memcached_default_mib  = 64 # the -m default memcached has been running on
  memcached_observed_mib = 28 # buffers, hash table and stacks it allocates outside -m today

  memcached_item_mib     = local.memcached_default_mib * 3  # as far as the host's ~470 MiB spare goes
  memcached_overhead_mib = local.memcached_observed_mib * 2 # the hash table grows with the budget
  memcached_mib          = local.memcached_item_mib + local.memcached_overhead_mib
}
