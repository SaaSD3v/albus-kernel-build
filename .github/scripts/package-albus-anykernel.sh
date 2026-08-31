#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <anykernel-dir> <kernel-image> <output-zip> <kernel-string>" >&2
  exit 2
fi

ANYKERNEL_DIR="$1"
KERNEL_IMAGE="$2"
OUTPUT_ZIP="$3"
KERNEL_STRING="$4"

[ -d "$ANYKERNEL_DIR/tools" ] || { echo "AnyKernel3 tools directory not found" >&2; exit 1; }
[ -f "$KERNEL_IMAGE" ] || { echo "Kernel image not found: $KERNEL_IMAGE" >&2; exit 1; }

cp "$KERNEL_IMAGE" "$ANYKERNEL_DIR/Image.gz"

cat > "$ANYKERNEL_DIR/anykernel.sh" <<EOF
### AnyKernel3 Ramdisk Mod Script
## Motorola Moto Z2 Play (albus)

properties() { '
kernel.string=${KERNEL_STRING}
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
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; }

# albus recovery fstab: /dev/block/bootdevice/by-name/boot
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

. tools/ak3-core.sh;

ui_print " ";
ui_print "Albus kernel installer";
ui_print "Target: \$BLOCK";
ui_print "Replacing kernel while preserving ramdisk/DT";

[ -e "\$BLOCK" ] || abort "Albus boot partition not found: \$BLOCK";
[ -f "\$AKHOME/Image.gz" ] || abort "Image.gz missing from kernel ZIP";

# Kernel-only install: dump/split the existing boot, keep its ramdisk and DT,
# rebuild it with this ZIP's Image.gz, then write it back to the same boot block.
split_boot;
flash_boot;

ui_print "Kernel written to albus boot partition";
EOF

# Packaging safety checks.
grep -q '^BLOCK=/dev/block/bootdevice/by-name/boot;$' "$ANYKERNEL_DIR/anykernel.sh"
grep -q '^IS_SLOT_DEVICE=0;$' "$ANYKERNEL_DIR/anykernel.sh"
grep -q '^device.name1=albus$' "$ANYKERNEL_DIR/anykernel.sh"
grep -q '^split_boot;$' "$ANYKERNEL_DIR/anykernel.sh"
grep -q '^flash_boot;$' "$ANYKERNEL_DIR/anykernel.sh"
if grep -Eqi 'tuna|toroplus|omap_hsmmc|XT1789' "$ANYKERNEL_DIR/anykernel.sh"; then
  echo "Invalid foreign-device reference found in anykernel.sh" >&2
  exit 1
fi

rm -f "$OUTPUT_ZIP"
(
  cd "$ANYKERNEL_DIR"
  zip -r9 "$OUTPUT_ZIP" . -x '.git/*' '.github/*' '*.zip'
)

echo "Created $OUTPUT_ZIP"
