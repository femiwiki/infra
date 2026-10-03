# The snapshots and the AMI left in Tokyo, from servers long gone. Imported only
# so that the next change deletes them on the record (femiwiki/femiwiki#616,
# femiwiki/femiwiki#617).
locals {
  tokyo_leftover_snapshots = {
    "snap-04fe903f8d9dcf80f" = {
      volume_id   = "vol-0f20aa5a6322990db"
      description = "a snapshot of EBS that is used by the previous main server"
      tags        = { note = "Docker swarm을 쓰던 인스턴스 디스크의 혹시 모를 백업" }
    }
    "snap-0f35ec801d79cb219" = {
      volume_id   = "vol-02282892a18b95bab"
      description = "Created by CreateImage(i-0d5d3ca84acd23d1e) for ami-0e9fe18644e3b1cca"
      tags        = {}
    }
  }
}

import {
  for_each = local.tokyo_leftover_snapshots

  to = aws_ebs_snapshot.tokyo_leftover[each.key]
  id = "${each.key}@${local.tokyo_region}"
}

resource "aws_ebs_snapshot" "tokyo_leftover" {
  for_each = local.tokyo_leftover_snapshots

  region      = local.tokyo_region
  volume_id   = each.value.volume_id
  description = each.value.description
  tags        = each.value.tags

  lifecycle {
    ignore_changes = all
  }
}

import {
  to = aws_ami.tokyo_leftover
  id = "ami-0e9fe18644e3b1cca@${local.tokyo_region}"
}

resource "aws_ami" "tokyo_leftover" {
  region              = local.tokyo_region
  name                = "2024-07-22 downed"
  architecture        = "arm64"
  boot_mode           = "uefi"
  ena_support         = true
  imds_support        = "v2.0"
  root_device_name    = "/dev/xvda"
  sriov_net_support   = "simple"
  virtualization_type = "hvm"

  ebs_block_device {
    device_name           = "/dev/xvda"
    snapshot_id           = aws_ebs_snapshot.tokyo_leftover["snap-0f35ec801d79cb219"].id
    volume_size           = 20
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = all
  }
}
