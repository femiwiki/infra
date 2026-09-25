locals {
  fastcgi_generation = 50

  memcached_default_mib  = 64 # the -m default memcached has been running on
  memcached_observed_mib = 28 # buffers, hash table and stacks it allocates outside -m today

  memcached_item_mib     = local.memcached_default_mib * 3  # as far as the host's ~470 MiB spare goes
  memcached_overhead_mib = local.memcached_observed_mib * 2 # the hash table grows with the budget
  memcached_mib          = local.memcached_item_mib + local.memcached_overhead_mib
}
