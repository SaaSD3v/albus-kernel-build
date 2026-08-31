# Albus Kernel Build

Automated kernel builds for Motorola Moto Z2 Play (albus).

## Supported branches

- `lineage-15.1`
- `lineage-18.1`

## Which variant should I use?

### LineageOS 15.1

| Variant | KernelSU / ReSukiSU | DroidSpaces / fixes | Optional flags | Recommended when... |
|---|---|---|---|---|
| **NORMAL** | ✅ Included | ✅ Included | ✅ Included | You want the complete build with KSU and all optional features. |
| **OPTIONAL** | ✅ Included | ✅ Included | ❌ Removed | You want KSU + DroidSpaces/fixes, but **without the optional flags**. |
| **NO-KSU** | ❌ Removed | ✅ Included | ✅ Included | You want DroidSpaces/fixes and optional features, but **without KernelSU**. |
| **NO-KSU OPTIONAL** | ❌ Removed | ✅ Included | ❌ Removed | You want DroidSpaces/fixes with neither KernelSU nor the optional flags. |

> **Example:** LineageOS 15.1 + KSU + no optional flags = **`15.1 OPTIONAL`**.

### LineageOS 18.1

| Variant | KernelSU / ReSukiSU | Branch fixes | Optional flags | Recommended when... |
|---|---|---|---|---|
| **NORMAL** | ✅ Included | ✅ Included | Branch default | You want the normal complete 18.1 build with KSU. |
| **OPTIONAL** | ✅ Included | ✅ Included | Optional set excluded | You want the 18.1 KSU build without optional additions. |
| **NO-KSU** | ❌ Removed | ✅ Included | Branch default | You want the normal 18.1 build without KernelSU. |
| **NO-KSU OPTIONAL** | ❌ Removed | ✅ Included | Optional set excluded | You want 18.1 without KernelSU and without optional additions. |

> The separate optional-firewall commit used by 15.1 was never added to the 18.1 branch, so the 18.1 OPTIONAL variants intentionally keep the branch's own native configuration instead of importing/removing 15.1-specific flags.

## Quick selection

- **Want everything + KSU:** `NORMAL`
- **Want KSU but no optional flags:** `OPTIONAL`
- **Want everything except KSU:** `NO-KSU`
- **Want no KSU and no optional flags:** `NO-KSU OPTIONAL`

## Installation

The generated ZIPs use an AnyKernel3 installer configured specifically for **albus**. Flash the kernel ZIP from recovery and reboot.

## Downloads

Each successful workflow publishes the kernel ZIP as a GitHub Actions artifact and uploads it to GoFile when `GOFILE_TOKEN` is configured.

## Usage

Open the **Actions** tab, select the workflow matching your Android branch and desired variant, then choose **Run workflow**.
