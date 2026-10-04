#!/usr/bin/env bash
# Refuse a pull request that could not merge once applied, since its apply would leave production ahead of main.
set -euo pipefail

: "${REPO:?}" "${PR:?}"
OWN=${OWN:-tofu gate}
TIMEOUT=${TIMEOUT:-600}

summary() {
  [ -z "${GITHUB_STEP_SUMMARY:-}" ] || printf '%s\n' "$@" >> "$GITHUB_STEP_SUMMARY"
}

refuse() {
  echo "$1"
  [ -z "${GITHUB_ACTIONS:-}" ] || echo "::error::$2"
  summary "### Not offered for approval" "" "$2" "" \
    "Fix it and push, or once it is green, re-run the failed jobs of this run."
  exit 1
}

base=$(gh api "repos/$REPO/pulls/$PR" --jq .base.ref)
required=$(
  {
    gh api "repos/$REPO/branches/$base" --jq '.protection.required_status_checks.contexts[]?'
    gh api "repos/$REPO/rules/branches/$base" \
      --jq '.[] | select(.type == "required_status_checks") | .parameters.required_status_checks[].context'
  } | sort -u | grep -vxF "$OWN" || true
)
[ -n "$required" ] || refuse "REQUIRED CHECKS UNKNOWN" "could not read the required checks of $base."

deadline=$(($(date +%s) + TIMEOUT))
while :; do
  read -r head mergeable < <(gh api "repos/$REPO/pulls/$PR" --jq '"\(.head.sha) \(.mergeable)"')
  results=$(
    gh api "repos/$REPO/commits/$head/check-runs" --paginate \
      --jq '.check_runs[] | [.name, (.conclusion // .status)] | @tsv'
    gh api "repos/$REPO/commits/$head/status" --jq '.statuses[] | [.context, .state] | @tsv'
  )
  failing='' waiting=''
  while read -r context; do
    states=$(awk -F '\t' -v c="$context" '$1 == c { print $2 }' <<< "$results")
    if [ -z "$states" ]; then
      waiting="$waiting, $context"
    elif grep -qvxE 'success|neutral|skipped|queued|in_progress|waiting|requested|pending' <<< "$states"; then
      failing="$failing, $context"
    elif grep -qvxE 'success|neutral|skipped' <<< "$states"; then
      waiting="$waiting, $context"
    fi
  done <<< "$required"
  failing=${failing#, } waiting=${waiting#, }

  if [ -n "$failing" ]; then
    refuse "CHECKS FAILING: $failing" "$failing failed on ${head:0:7}, so the pull request could not merge after its apply."
  elif [ "$mergeable" = false ]; then
    refuse "CONFLICTS" "the pull request conflicts with $base, so it could not merge after its apply."
  elif [ -z "$waiting" ] && [ "$mergeable" = true ]; then
    echo "MERGEABLE (required: $(paste -sd, <<< "$required" | sed 's/,/, /g'))"
    exit 0
  elif [ "$(date +%s)" -ge "$deadline" ]; then
    [ "$mergeable" = true ] || waiting="${waiting:+$waiting, }mergeability"
    refuse "CHECKS PENDING: $waiting" "$waiting had not finished within ${TIMEOUT}s."
  fi
  sleep 15
done
