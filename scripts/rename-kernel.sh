#!/bin/bash
# Rename kernel LOCALVERSION from CrystalTWRP-albus to twrp-albus
# This modifies the kernel binary - use at your own risk

INPUT="$1"
OUTPUT="$2"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <input_kernel> <output_kernel>"
    exit 1
fi

# Copy the kernel
cp "$INPUT" "$OUTPUT"

# Replace CrystalTWRP-albus with twrp-albus (pad with null bytes)
# CrystalTWRP-albus = 18 chars
# twrp-albus = 10 chars
# Need to pad with 8 null bytes
sed -i 's/CrystalTWRP-albus/twrp-albus\x00\x00\x00\x00\x00\x00\x00\x00/g' "$OUTPUT"

echo "Renamed kernel LOCALVERSION"
echo "Original: $(wc -c < "$INPUT") bytes"
echo "Modified: $(wc -c < "$OUTPUT") bytes"
