#!/bin/bash
set -euo pipefail

# The release a host booted from gets no new packages, so count against the
# latest one (femiwiki/femiwiki#613)
dir=/var/lib/node_exporter/textfile_collector
mkdir -p "$dir"
tmp=$(mktemp "$dir/.dnf.XXXXXX")
trap 'rm -f "$tmp"' EXIT

# dnf prints a line per package; each advisory is counted once, and every
# severity is written even at zero so the alert never sees no data
dnf -q updateinfo list --security --releasever=latest |
  awk '
    BEGIN { n["Critical"] = 0; n["Important"] = 0; n["Medium"] = 0; n["Low"] = 0 }
    NF == 3 && !seen[$1]++ { sub(/\/Sec\.$/, "", $2); n[$2]++ }
    END {
      print "# HELP dnf_security_advisories Security advisories that dnf upgrade --releasever=latest would apply."
      print "# TYPE dnf_security_advisories gauge"
      for (s in n) printf "dnf_security_advisories{severity=\"%s\"} %d\n", s, n[s]
    }
  ' >"$tmp"

chmod 0644 "$tmp"
mv -f "$tmp" "$dir/dnf.prom"
cat "$dir/dnf.prom"
