#!/usr/bin/env bash
# Femiwiki edge reconciler.
#
# Resolves the backend ASG (InService + HEALTHY) -> private IPs, gates each node on a
# direct /healthz-ready probe, and publishes the result as the edge Caddy reverse_proxy
# upstreams via the admin API (atomic add-before-remove PATCH on the @id-tagged handler).
# Couples the TERMINATING lifecycle hook with a real drain window. Floor-of-one: never
# publishes an empty upstream set. Idempotent + crash-only: safe to run every ~20s and on
# every Caddy (re)start.
#
# The LAUNCHING hook is owned by the node's own user-data (it polls local /healthz-ready
# then CompleteLifecycleAction). This daemon does NOT touch the launch hook (single owner).
set -euo pipefail

# ---- config (overridable via /etc/femiwiki/reconciler.env) -------------------
: "${AWS_DEFAULT_REGION:=ap-northeast-1}"
: "${ASG_NAME:?ASG_NAME is required}"
: "${TERMINATE_HOOK:=femiwiki-app-terminate}"
: "${BACKEND_PORT:=8080}"
# Add-gate: a NEW node must pass real readiness (DB + memcached + session store) to JOIN.
: "${READY_PATH:=/healthz-ready}"
# Keep/evict: an EXISTING node is only removed/evicted on process LIVENESS failure, so a
# shared MySQL/memcached blip cannot eject the fleet (decoupled from readiness; see D4).
: "${LIVE_PATH:=/healthz-live}"
: "${CADDY_ADMIN:=http://localhost:2019}"
: "${CADDY_ID:=backend_upstreams}"
: "${CADDY_CONTAINER:=http}"
# The edge `http` image bakes its Caddyfile at /srv/femiwiki.com/Caddyfile (Dockerfile:
# COPY Caddyfile into /srv/femiwiki.com/ + WORKDIR /srv/femiwiki.com). NOT /etc/caddy.
: "${CADDY_CONFIG_PATH:=/srv/femiwiki.com/Caddyfile}"
: "${STATE_DIR:=/var/lib/femiwiki-reconciler}"
: "${TEXTFILE_DIR:=/var/lib/node_exporter/textfile}"
: "${PROBE_TIMEOUT:=3}"
: "${UNHEALTHY_THRESHOLD:=3}"
# Seconds an instance must remain OUT of upstreams before its terminate hook is released,
# so in-flight requests on the draining node finish before the EC2 instance is terminated.
: "${DRAIN_WINDOW:=20}"
: "${CW_NAMESPACE:=Femiwiki/Reconciler}"
export AWS_DEFAULT_REGION

LAST_GOOD="${STATE_DIR}/upstreams.json"
LIVEDIR="${STATE_DIR}/livefail"
TERMDIR="${STATE_DIR}/terminating"
mkdir -p "$STATE_DIR" "$LIVEDIR" "$TERMDIR" "$TEXTFILE_DIR"

log() { printf '%s reconciler: %s\n' "$(date -u +%FT%TZ)" "$*" >&2; }

patch_failures=0
aws_errors=0
success=0
upstream_count=0
floor_breach=0
draining=0

emit_metrics() {
  local now tmp
  now=$(date +%s)
  tmp="${TEXTFILE_DIR}/.femiwiki_reconciler.prom.$$"
  {
    echo "# TYPE femiwiki_reconciler_up gauge"
    echo "femiwiki_reconciler_up ${success}"
    echo "# TYPE femiwiki_reconciler_last_success_timestamp_seconds gauge"
    [ "$success" = 1 ] && echo "femiwiki_reconciler_last_success_timestamp_seconds ${now}"
    echo "# TYPE femiwiki_reconciler_upstream_count gauge"
    echo "femiwiki_reconciler_upstream_count ${upstream_count}"
    echo "# TYPE femiwiki_reconciler_floor_breach gauge"
    echo "femiwiki_reconciler_floor_breach ${floor_breach}"
    echo "# TYPE femiwiki_reconciler_draining gauge"
    echo "femiwiki_reconciler_draining ${draining}"
    echo "# TYPE femiwiki_reconciler_patch_failures_total counter"
    echo "femiwiki_reconciler_patch_failures_total ${patch_failures}"
    echo "# TYPE femiwiki_reconciler_aws_errors_total counter"
    echo "femiwiki_reconciler_aws_errors_total ${aws_errors}"
  } > "$tmp" && mv -f "$tmp" "${TEXTFILE_DIR}/femiwiki_reconciler.prom"
  # CloudWatch is the load-bearing alarm path (PutMetricData granted by
  # CloudWatchAgentServerPolicy already on the edge role).
  aws cloudwatch put-metric-data --namespace "$CW_NAMESPACE" --metric-data \
    "MetricName=UpstreamCount,Value=${upstream_count},Unit=Count" \
    "MetricName=ReconcilerHeartbeat,Value=${success},Unit=Count" >/dev/null 2>&1 || true
}
trap emit_metrics EXIT

aws_q() { aws "$@" 2>/dev/null || { aws_errors=$((aws_errors + 1)); return 1; }; }
probe() { [ "$(curl -fsS -m "$PROBE_TIMEOUT" -o /dev/null -w '%{http_code}' "http://$1:${BACKEND_PORT}$2" 2>/dev/null)" = 200 ]; }
caddy_current() { curl -fsS -m 5 "${CADDY_ADMIN}/id/${CADDY_ID}/upstreams" | jq -r '.[].dial' | sort; }

# Adapt the LIVE Caddyfile, inject @id + seed last-good upstreams, POST /load.
bootstrap_id() {
  local seed='[]'
  [ -s "$LAST_GOOD" ] && seed="$(cat "$LAST_GOOD")"
  log "bootstrap: injecting @id=${CADDY_ID} (config=${CADDY_CONFIG_PATH})"
  if ! docker exec "$CADDY_CONTAINER" caddy adapt \
    --config "$CADDY_CONFIG_PATH" --adapter caddyfile \
    | jq --arg id "$CADDY_ID" --argjson seed "$seed" '
        (.. | objects | select(.handler? == "reverse_proxy"))
          |= (. + {"@id": $id} + (if ($seed|length) > 0 then {upstreams: $seed} else {} end))' \
    | curl -fsS -m 10 -X POST -H 'Content-Type: application/json' \
        --data-binary @- "${CADDY_ADMIN}/load"; then
    log "bootstrap: /load failed"
    patch_failures=$((patch_failures + 1))
    return 1
  fi
}

exec 9>"${STATE_DIR}/.lock"
flock -n 9 || { log "another run holds the lock; skipping"; exit 0; }

# 1. instances of THIS ASG only
asg=$(aws_q autoscaling describe-auto-scaling-instances \
  --query "AutoScalingInstances[?AutoScalingGroupName=='${ASG_NAME}']" --output json) \
  || { log "describe-asg-instances failed"; exit 0; }

serving_ids=$(echo "$asg" | jq -r '.[] | select(.HealthStatus=="HEALTHY") | select(.LifecycleState=="InService") | .InstanceId')
term_ids=$(echo "$asg" | jq -r '.[] | select(.LifecycleState | startswith("Terminating:Wait")) | .InstanceId')

# 2. private IPs of the serving candidates
declare -A IP_OF
if [ -n "$serving_ids" ]; then
  # shellcheck disable=SC2086,SC2016
  ipmap=$(aws_q ec2 describe-instances --instance-ids $serving_ids \
    --query 'Reservations[].Instances[?State.Name==`running`].{id:InstanceId,ip:PrivateIpAddress}' \
    --output json | jq -r '.[][] | "\(.id) \(.ip)"') || { log "describe-instances failed"; exit 0; }
  while read -r id ip; do
    [ -z "${ip:-}" ] && continue
    IP_OF["$id"]="$ip"
  done <<< "$ipmap"
fi

# previous published set (sticky membership)
last_set=()
if [ -s "$LAST_GOOD" ]; then
  mapfile -t last_set < <(jq -r '.[].dial' "$LAST_GOOD" 2>/dev/null)
fi
was_in() {
  local d="$1" x
  for x in "${last_set[@]:-}"; do [ "$x" = "$d" ] && return 0; done
  return 1
}

# 3. build the desired set: a node must be LIVE; readiness is required only to JOIN, never
#    to stay (was_in). This + health_uri=/healthz-live in Caddy decouples shared-dep blips
#    from ejection. Track liveness failures for eviction.
ready_dials=()
for id in $serving_ids; do
  ip="${IP_OF[$id]:-}"
  [ -z "$ip" ] && continue
  dial="${ip}:${BACKEND_PORT}"
  if probe "$ip" "$LIVE_PATH"; then
    rm -f "${LIVEDIR}/${id}"
    if probe "$ip" "$READY_PATH" || was_in "$dial"; then
      ready_dials+=("$dial")
    else
      log "join-gate HOLD ${id} ${ip} (live but not yet ready)"
    fi
  else
    c=$(( $(cat "${LIVEDIR}/${id}" 2>/dev/null || echo 0) + 1 ))
    echo "$c" > "${LIVEDIR}/${id}"
    log "liveness FAIL ${id} ${ip} (consecutive=${c})"
  fi
done

desired=""
if [ "${#ready_dials[@]}" -gt 0 ]; then
  desired=$(printf '%s\n' "${ready_dials[@]}" | sort -u)
fi
[ -n "$desired" ] && upstream_count=$(printf '%s\n' "$desired" | grep -c .)
in_desired() { printf '%s\n' "$desired" | grep -qx "$1"; }

# 4. FLOOR-OF-ONE: never publish an empty set; keep last-good and alarm.
if [ "$upstream_count" -lt 1 ]; then
  log "ZERO ready upstreams -> refusing to PATCH; keeping last-good. ALARM."
  floor_breach=1
  exit 0
fi

# 5. diff vs Caddy, atomic add-before-remove PATCH (whole-config reload, rolled back on err)
if ! current=$(caddy_current); then
  bootstrap_id || exit 0
  current=$(caddy_current || true)
fi
body=$(printf '%s\n' "$desired" | grep . | jq -R . | jq -s 'map({dial: .})')
if [ "$desired" != "$current" ]; then
  if curl -fsS -m 10 -X PATCH -H 'Content-Type: application/json' \
    -d "$body" "${CADDY_ADMIN}/id/${CADDY_ID}/upstreams" >/dev/null; then
    log "PATCHed upstreams -> $(echo "$desired" | tr '\n' ' ')"
    printf '%s' "$body" > "$LAST_GOOD"
  else
    log "PATCH failed"
    patch_failures=$((patch_failures + 1))
    exit 0
  fi
else
  printf '%s' "$body" > "$LAST_GOOD"
fi

# 6. TERMINATE hook: the node is already out of upstreams (it is not in serving_ids). Hold
#    a real drain window (record removed_at on first sighting) so in-flight requests finish,
#    and only CONTINUE once a healthy peer survives. Heartbeat to keep the hook alive.
cur_terms=" $(echo "$term_ids" | tr '\n' ' ') "
now=$(date +%s)
for id in $term_ids; do
  stamp="${TERMDIR}/${id}"
  [ -f "$stamp" ] || echo "$now" > "$stamp"
  removed_at=$(cat "$stamp")
  age=$(( now - removed_at ))
  if [ "$upstream_count" -ge 1 ] && [ "$age" -ge "$DRAIN_WINDOW" ]; then
    log "terminate-gate PASS ${id}: drained ${age}s, ${upstream_count} peer(s) -> CONTINUE"
    aws_q autoscaling complete-lifecycle-action --lifecycle-action-result CONTINUE \
      --lifecycle-hook-name "$TERMINATE_HOOK" --auto-scaling-group-name "$ASG_NAME" \
      --instance-id "$id" >/dev/null && rm -f "$stamp" || true
  else
    draining=$((draining + 1))
    log "terminate-gate DRAIN ${id}: age=${age}s/${DRAIN_WINDOW}s peers=${upstream_count} -> heartbeat"
    aws_q autoscaling record-lifecycle-action-heartbeat \
      --lifecycle-hook-name "$TERMINATE_HOOK" --auto-scaling-group-name "$ASG_NAME" \
      --instance-id "$id" >/dev/null || true
  fi
done
# prune stale terminate stamps (instances no longer terminating)
for stamp in "$TERMDIR"/*; do
  [ -e "$stamp" ] || continue
  sid=$(basename "$stamp")
  case "$cur_terms" in *" $sid "*) : ;; *) rm -f "$stamp" ;; esac
done

# 7. blackhole protection: evict an InService node that keeps failing LIVENESS, only if a
#    healthy (live) peer survives. Uses liveness, not readiness, so a DB blip never evicts.
for id in $serving_ids; do
  c=$(cat "${LIVEDIR}/${id}" 2>/dev/null || echo 0)
  if [ "$c" -ge "$UNHEALTHY_THRESHOLD" ]; then
    peer=$(printf '%s\n' "$desired" | grep -vx "${IP_OF[$id]:-x}:${BACKEND_PORT}" | grep -c . || true)
    if [ "${peer:-0}" -ge 1 ]; then
      log "SetInstanceHealth Unhealthy ${id} (failed ${c} liveness probes)"
      aws_q autoscaling set-instance-health --instance-id "$id" --health-status Unhealthy >/dev/null \
        && rm -f "${LIVEDIR}/${id}" || true
    fi
  fi
done

success=1
log "done: ${upstream_count} upstream(s), ${draining} draining"
