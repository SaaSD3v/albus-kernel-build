# Albus TWRP Recovery

## Recovery Image

The `twrp-src/twrp.img` is a **prebuilt** recovery image with:

- **Kernel**: CrystalTWRP 3.18.71 (albus)
- **Builder**: crystal@albus-builder
- **GCC**: 4.9.x 20150123 (prerelease)
- **DroidSpaces**: Enabled (SYSVIPC, namespaces, cgroups, etc.)
- **Size**: 20.7MB (fits in 20.09MB recovery partition)

## Kernel Source

The CrystalTWRP kernel source **is no longer available** online. This recovery.img is a prebuilt that was rescued from an old build. Do not attempt to rebuild it - use it as-is.

## What's Inside

- **KERNEL_SZ**: 9,762,564 bytes (gzip compressed)
- **RAMDISK_SZ**: 8,184,108 bytes (lzma compressed)
- **EXTRA_SZ**: 1,765,376 bytes (DTB)
- **Kernel version**: 3.18.71-CrystalTWRP-albus
- **Compression**: gzip (kernel), lzma (ramdisk)

## Usage

Flash directly:
```
fastboot flash recovery twrp-src/twrp.img
```

Or use the workflow "Build Albus TWRP (Prebuilt)" to get the artifact.

## Workflows

- **Analyze Recovery**: Unpacks and analyzes the recovery.img
- **Build Albus TWRP (Prebuilt)**: Outputs the prebuilt recovery.img
- **TWRP Patch**: Replaces kernel in TWRP with custom kernel (experimental)
