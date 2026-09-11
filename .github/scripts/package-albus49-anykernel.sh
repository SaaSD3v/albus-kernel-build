#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <anykernel-dir> <Image.gz> <dtb-image> <output-zip> <kernel-string>" >&2
  exit 2
fi

AK="$1"
IMAGE="$2"
DTB="$3"
OUT="$4"
KSTRING="$5"

[ -d "$AK/tools" ] || { echo "AnyKernel3 tools not found" >&2; exit 1; }
[ -s "$IMAGE" ] || { echo "Kernel image missing: $IMAGE" >&2; exit 1; }
[ -s "$DTB" ] || { echo "Separated DTB image missing: $DTB" >&2; exit 1; }

cp "$IMAGE" "$AK/Image.gz"
cp "$DTB" "$AK/dtb"

cat > "$AK/anykernel.sh" <<EOF
### AnyKernel3 Ramdisk Mod Script
## Moto Z2 Play (albus) - Linux 4.9 test kernel

properties() { '
kernel.string=${KSTRING}
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=albus
device.name2=albus_retail
device.name3=
device.name4=
device.name5=
supported.versions=8.1
supported.patchlevels=
supported.vendorpatchlevels=
'; }

BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

. tools/ak3-core.sh;

ui_print " ";
ui_print "Albus Linux 4.9 DroidSpaces kernel";
ui_print "Replacing kernel and separated DTB";
ui_print "Preserving the current LOS 15.1 ramdisk";

[ -e "\$BLOCK" ] || abort "Albus boot partition not found: \$BLOCK";
[ -f "\$AKHOME/Image.gz" ] || abort "Image.gz missing";
[ -f "\$AKHOME/dtb" ] || abort "4.9 dtb image missing";

split_boot;
flash_boot;
EOF

rm -f "$OUT"
(
  cd "$AK"
  zip -r9 "$OUT" . -x '.git/*' '.github/*' '*.zip'
)

echo "Created $OUT"
