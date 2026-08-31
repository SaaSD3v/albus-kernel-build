#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-}"
if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
  echo "usage: $0 <kernel .config>" >&2
  exit 2
fi

required_y=(
  CONFIG_NAMESPACES
  CONFIG_UTS_NS
  CONFIG_IPC_NS
  CONFIG_PID_NS
  CONFIG_NET_NS
  CONFIG_CGROUPS
  CONFIG_CGROUP_DEVICE
  CONFIG_CGROUP_FREEZER
  CONFIG_CPUSETS
  CONFIG_CGROUP_CPUACCT
  CONFIG_MEMCG
  CONFIG_POSIX_MQUEUE
  CONFIG_SECCOMP
  CONFIG_NETFILTER
  CONFIG_NETFILTER_XTABLES
  CONFIG_NF_CONNTRACK
  CONFIG_NETFILTER_XT_MATCH_CONNTRACK
  CONFIG_NETFILTER_XT_MATCH_ADDRTYPE
  CONFIG_IP_NF_FILTER
  CONFIG_IP_NF_NAT
  CONFIG_IP_NF_TARGET_MASQUERADE
  CONFIG_VETH
  CONFIG_BRIDGE
  CONFIG_OVERLAY_FS
  CONFIG_UNIX98_PTYS
  CONFIG_DEVPTS_MULTIPLE_INSTANCES
)

failed=0
for sym in "${required_y[@]}"; do
  if grep -qx "${sym}=y" "$CONFIG"; then
    printf 'OK      %s=y\n' "$sym"
  else
    printf 'MISSING %s=y\n' "$sym" >&2
    failed=1
  fi
done

if grep -q '^CONFIG_ANDROID_PARANOID_NETWORK=y$' "$CONFIG"; then
  echo 'BROKEN  CONFIG_ANDROID_PARANOID_NETWORK must remain disabled for DroidSpaces/Docker' >&2
  failed=1
else
  echo 'OK      CONFIG_ANDROID_PARANOID_NETWORK disabled'
fi

warn_if_off() {
  local sym="$1" msg="$2"
  if ! grep -qx "${sym}=y" "$CONFIG"; then
    echo "::warning::${sym} is disabled: ${msg}"
  fi
}

warn_if_off CONFIG_USER_NS 'rootless/user-namespace container modes are unavailable; rootful Docker is not blocked'
warn_if_off CONFIG_CFS_BANDWIDTH 'Docker CPU CFS quota/--cpus limits may be unavailable'
warn_if_off CONFIG_BLK_CGROUP 'Docker block-I/O cgroup limits are unavailable'
warn_if_off CONFIG_NETFILTER_XT_TARGET_CHECKSUM 'some advanced container/bridge networking paths may lack CHECKSUM target support'
warn_if_off CONFIG_VLAN_8021Q '802.1Q VLAN-dependent container networking modes are unavailable'

if [ "$failed" -ne 0 ]; then
  echo 'Container compatibility gate FAILED.' >&2
  exit 1
fi

echo 'Container compatibility gate PASSED.'
