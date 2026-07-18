# Build Kernel Albus

Kernel build for Moto Z2 Play (albus) with AnyKernel support.

## Kernel Source

https://github.com/SaaSD3v/android_kernel_motorola_msm8996

## How to Build

1. Go to **Actions** tab
2. Click **Build Albus Kernel** workflow
3. Click **Run workflow**
4. Wait for the build to complete
5. Download the artifact from the **Artifacts** section

## Device Info

| Item | Value |
|---|---|
| Device | Moto Z2 Play |
| Codename | albus |
| SoC | Qualcomm MSM8953 |
| Kernel | 3.18.71 |
| Android | 8.1 (LineageOS 15.1) |
| Partition | a-only |

## Flash

1. Boot into recovery (TWRP)
2. Flash the zip from **Install**
3. Reboot

## Build Toolchain

- GCC 4.9 (NDK r17c)