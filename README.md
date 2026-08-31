# Albus Kernel Build

Automated kernel builds for Motorola Moto Z2 Play (albus).

## Supported branches

- `lineage-15.1`
- `lineage-18.1`

## Variants

### LineageOS 15.1

| Variant | KSU | Optional flags | Use this when... |
|---|---|---|---|
| **NORMAL** | ✅ | ✅ | You want the complete build. |
| **OPTIONAL** | ✅ | ❌ | You want KSU without the optional flags. |
| **NO-KSU** | ❌ | ✅ | You want the build without KSU. |
| **NO-KSU OPTIONAL** | ❌ | ❌ | You want neither KSU nor the optional flags. |

### LineageOS 18.1

| Variant | KSU | Optional flags | Use this when... |
|---|---|---|---|
| **NORMAL** | ✅ | Branch default | You want the normal build with KSU. |
| **OPTIONAL** | ✅ | Excluded where applicable | You want KSU without optional additions. |
| **NO-KSU** | ❌ | Branch default | You want the normal build without KSU. |
| **NO-KSU OPTIONAL** | ❌ | Excluded where applicable | You want neither KSU nor optional additions. |

## Quick selection

- KSU + optional flags: `NORMAL`
- KSU + no optional flags: `OPTIONAL`
- No KSU + optional flags: `NO-KSU`
- No KSU + no optional flags: `NO-KSU OPTIONAL`

## Installation

Flash the generated kernel ZIP from recovery and reboot.

## Downloads

Each successful workflow publishes the kernel ZIP as a GitHub Actions artifact and uploads it to GoFile when configured.

## Usage

Open the **Actions** tab, select the workflow matching the Android branch and desired variant, then choose **Run workflow**.
