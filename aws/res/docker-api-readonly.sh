#!/bin/bash
set -euo pipefail

# A host's own copy, so a new host answers a pull request's docker plan as soon
# as it boots, before any docker apply has reached it
NAME=docker-api-readonly
IMAGE=__IMAGE__
SPEC="$IMAGE CONTAINERS=1 IMAGES=1 INFO=1 NETWORKS=1 VOLUMES=1"

current=$(docker inspect --format '{{index .Config.Labels "spec"}} {{.State.Running}}' "$NAME" 2>/dev/null || true)
[ "$current" = "$SPEC true" ] && exit 0

docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run --detach --name "$NAME" --label "spec=$SPEC" \
  --restart always --network host --memory 64m --memory-swap 64m \
  --ulimit nofile=32768:65536 \
  --log-driver fluentd --log-opt fluentd-address=127.0.0.1:24224 --log-opt fluentd-async=true \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --env BIND_CONFIG=127.0.0.1:2377 \
  --env CONTAINERS=1 --env IMAGES=1 --env INFO=1 --env NETWORKS=1 --env VOLUMES=1 \
  "$IMAGE" >/dev/null
