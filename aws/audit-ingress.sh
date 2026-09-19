#!/usr/bin/env bash
#
# Fail if any security group accepts traffic from the whole internet on a port
# that is not meant to be public.
#
# This reads the live AWS API rather than the Terraform source on purpose. The
# two world-open rules found so far slipped past for opposite reasons:
# femiwiki/femiwiki#459 shipped 2376 through Terraform and nobody read the diff,
# while the SSH rule revoked on 2026-09-20 was added by hand, never existed in
# the source, and so could never have shown up as drift. Only the account knows
# what is actually open.
#
# Usage: aws/audit-ingress.sh [region ...]
#
set -euo pipefail

regions=("$@")
if [ ${#regions[@]} -eq 0 ]; then
  regions=(ap-northeast-1)
fi

# Ports the public internet is supposed to reach. Anything else must be bounded
# by a CIDR or a source security group.
public_ports='[80, 443]'

status=0

for region in "${regions[@]}"; do
  groups=$(aws ec2 describe-security-groups \
    --region "$region" \
    --query 'SecurityGroups[].{id:GroupId,name:GroupName}' \
    --output json)

  rules=$(aws ec2 describe-security-group-rules --region "$region" --output json)

  findings=$(
    jq -r \
      --argjson groups "$groups" \
      --argjson publicPorts "$public_ports" \
      --arg region "$region" '
        ($groups | map({key: .id, value: .name}) | from_entries) as $names
        | .SecurityGroupRules[]
        | select(.IsEgress == false)
        | select(.CidrIpv4 == "0.0.0.0/0" or .CidrIpv6 == "::/0")
        | . as $rule
        # A single allowed port, not a range that happens to start on one.
        | select(
            (
              $rule.FromPort == $rule.ToPort
              and ($publicPorts | index($rule.FromPort)) != null
            )
            | not
          )
        | [
            $region,
            ($names[.GroupId] // .GroupId),
            .SecurityGroupRuleId,
            (if .IpProtocol == "-1"
             then "all protocols, all ports"
             else "\(.IpProtocol)/\(.FromPort)-\(.ToPort)"
             end),
            (.CidrIpv4 // .CidrIpv6),
            (.Description // "")
          ]
        | @tsv
      ' <<<"$rules"
  )

  if [ -n "$findings" ]; then
    status=1
    printf '%s\n' "$findings"
  fi
done

if [ "$status" -ne 0 ]; then
  {
    echo
    echo "World-open ingress found on a port outside ${public_ports}."
    echo "Bound the rule to a CIDR or a source security group, or add the port"
    echo "to public_ports in this script and say why in the commit message."
  } >&2
  exit 1
fi

echo "No world-open ingress outside ${public_ports}."
