# Albus Kernel Build

Automated kernel builds for Motorola Moto Z2 Play (albus).

## Supported branches

- `lineage-15.1`
- `lineage-18.1`

## Variants

### LineageOS 15.1

| Variant | KSU | Optional additions | Use this when... |
|---|---|---|---|
| **NORMAL** | ✅ | Included | You want the complete build. |
| **OPTIONAL** | ✅ | Excluded | You want KSU without the optional additions. |
| **NO-KSU** | ❌ | Included | You want the build without KSU. |
| **NO-KSU OPTIONAL** | ❌ | Excluded | You want neither KSU nor the optional additions. |

### LineageOS 18.1

| Variant | KSU | Optional additions | Use this when... |
|---|---|---|---|
| **NORMAL** | ✅ | Branch default | You want the normal build with KSU. |
| **OPTIONAL** | ✅ | Excluded where applicable | You want KSU without optional additions. |
| **NO-KSU** | ❌ | Branch default | You want the normal build without KSU. |
| **NO-KSU OPTIONAL** | ❌ | Excluded where applicable | You want neither KSU nor optional additions. |

## Quick selection

- KSU + complete build: `NORMAL`
- KSU + no optional additions: `OPTIONAL`
- No KSU + complete build: `NO-KSU`
- No KSU + no optional additions: `NO-KSU OPTIONAL`

## Installation

Flash the generated kernel ZIP from recovery and reboot.

## Downloads

Each successful workflow publishes the kernel ZIP as a GitHub Actions artifact and uploads it to GoFile when configured.

## Usage

Open the **Actions** tab, select the workflow matching the Android branch and desired variant, then choose **Run workflow**.
