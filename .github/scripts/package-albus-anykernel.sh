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

BLOCK=boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

. tools/ak3-core.sh;

# Replace only the kernel while preserving the existing albus ramdisk and separate DT.
split_boot;
flash_boot;
EOF

# Safety checks: never ship the upstream Tuna/OMAP example by accident.
grep -q '^BLOCK=boot;$' "$ANYKERNEL_DIR/anykernel.sh"
grep -q '^IS_SLOT_DEVICE=0;$' "$ANYKERNEL_DIR/anykernel.sh"
grep -q '^device.name1=albus$' "$ANYKERNEL_DIR/anykernel.sh"
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
