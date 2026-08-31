#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) < 2:
    raise SystemExit("usage: apply-albus-network-fix.py <kernel-dir> [--addrtype]")

kernel = Path(sys.argv[1])
want_addrtype = "--addrtype" in sys.argv[2:]
defconfig = kernel / "arch/arm64/configs/albus_defconfig"
commoncap = kernel / "security/commoncap.c"

cfg = defconfig.read_text()
for old in (
    "CONFIG_ANDROID_PARANOID_NETWORK=y",
    "# CONFIG_ANDROID_PARANOID_NETWORK is not set",
    "CONFIG_ANDROID_PARANOID_NETWORK=n",
):
    cfg = cfg.replace(old, "CONFIG_ANDROID_PARANOID_NETWORK=n")
if cfg.count("CONFIG_ANDROID_PARANOID_NETWORK=n") != 1:
    raise SystemExit("unexpected ANDROID_PARANOID_NETWORK state")

if want_addrtype:
    cfg = cfg.replace(
        "# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set",
        "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y",
    )
    if "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y" not in cfg:
        raise SystemExit("failed to enable NETFILTER_XT_MATCH_ADDRTYPE")

defconfig.write_text(cfg)

src = commoncap.read_text()
include_old = "#ifdef CONFIG_ANDROID_PARANOID_NETWORK\n#include <linux/android_aid.h>\n#endif"
include_new = "#include <linux/android_aid.h>"
if include_old in src:
    src = src.replace(include_old, include_new, 1)
elif include_new not in src:
    raise SystemExit("android_aid include block not found")

caps_old = """#ifdef CONFIG_ANDROID_PARANOID_NETWORK
\tif (cap == CAP_NET_RAW && in_egroup_p(AID_NET_RAW))
\t\treturn 0;
\tif (cap == CAP_NET_ADMIN && in_egroup_p(AID_NET_ADMIN))
\t\treturn 0;
#endif"""
caps_new = """\tif (cap == CAP_NET_RAW && in_egroup_p(AID_NET_RAW))
\t\treturn 0;
\tif (cap == CAP_NET_ADMIN && in_egroup_p(AID_NET_ADMIN))
\t\treturn 0;"""
if caps_old in src:
    src = src.replace(caps_old, caps_new, 1)
elif caps_new not in src:
    raise SystemExit("legacy Android network capability block not found")

if "#ifdef CONFIG_ANDROID_PARANOID_NETWORK" in src:
    raise SystemExit("ANDROID_PARANOID_NETWORK still gates commoncap.c")
commoncap.write_text(src)

print("Albus network fix applied: paranoid=n, legacy Wi-Fi capabilities preserved")
if want_addrtype:
    print("NETFILTER_XT_MATCH_ADDRTYPE=y")
