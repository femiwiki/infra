locals {
  fastcgi_generation = 47

  memcached_item_mib     = 192
  memcached_overhead_mib = 64
  memcached_mib          = local.memcached_item_mib + local.memcached_overhead_mib
}
