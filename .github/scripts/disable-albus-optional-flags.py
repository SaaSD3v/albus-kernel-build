#!/usr/bin/env python3
"""Disable only the Albus 15.1 optional firewall feature set.

This intentionally edits symbols by name instead of relying on their position in
albus_defconfig.  It makes OPTIONAL builds independent from source formatting
and prevents removal of baseline netfilter options that happen to share the
same values.
"""

from pathlib import Path
import re
import sys

if len(sys.argv) != 2:
    raise SystemExit(f"usage: {sys.argv[0]} <defconfig>")

path = Path(sys.argv[1])
text = path.read_text()
lines = text.splitlines()

# These are the features introduced by the optional firewall/IP-set layer.
# Baseline Xtables/conntrack/NAT options are deliberately NOT listed here.
disable = [
    "CONFIG_IP_SET",
    "CONFIG_IP_SET_HASH_IP",
    "CONFIG_IP_SET_HASH_NET",
    "CONFIG_NETFILTER_XT_SET",
    "CONFIG_NETFILTER_XT_MATCH_RECENT",
    "CONFIG_NETFILTER_XT_MATCH_OWNER",
]

targets = set(disable)
config_line = re.compile(r"^(?:# )?(CONFIG_[A-Z0-9_]+)(?:=.*| is not set)$")
filtered = []
seen = {name: 0 for name in disable}

for line in lines:
    match = config_line.match(line)
    if match and match.group(1) in targets:
        seen[match.group(1)] += 1
        continue
    filtered.append(line)

# Keep a single authoritative state for every optional symbol.  Appending is
# safe for the temporary CI defconfig and avoids depending on Kconfig section
# layout.  olddefconfig will canonicalize the generated .config afterwards.
filtered.append("")
filtered.append("# Albus OPTIONAL variant: optional firewall/IP-set layer disabled")
for name in disable:
    filtered.append(f"# {name} is not set")

path.write_text("\n".join(filtered) + "\n")

print("Disabled optional symbols:")
for name in disable:
    print(f"  {name} (removed {seen[name]} source occurrence(s))")
