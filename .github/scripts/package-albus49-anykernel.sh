#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <anykernel-dir> <Image.gz-dtb> <output-zip> <kernel-string>" >&2
  exit 2
fi

AK="$1"
IMAGE_DTB="$2"
OUT="$3"
KSTRING="$4"

[ -d "$AK/tools" ] || { echo "AnyKernel3 tools not found" >&2; exit 1; }
[ -s "$IMAGE_DTB" ] || { echo "Appended kernel image missing: $IMAGE_DTB" >&2; exit 1; }

# Albus device trees declare BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb.
# Keep the DTBs appended to the kernel instead of presenting them as a
# separated boot-image DTB component.
rm -f "$AK/Image" "$AK/Image.gz" "$AK/Image.lz4" "$AK/Image.gz-dtb" "$AK/dtb" "$AK/dtbo"
cp "$IMAGE_DTB" "$AK/Image.gz-dtb"

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
ui_print "Replacing appended Image.gz-dtb";
ui_print "Preserving the current LOS 15.1 ramdisk";

[ -e "\$BLOCK" ] || abort "Albus boot partition not found: \$BLOCK";
[ -f "\$AKHOME/Image.gz-dtb" ] || abort "Image.gz-dtb missing";

split_boot;
flash_boot;
EOF

rm -f "$OUT"
(
  cd "$AK"
  zip -r9 "$OUT" . -x '.git/*' '.github/*' '*.zip'
)

echo "Created $OUT"