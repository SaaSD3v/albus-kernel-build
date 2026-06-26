### CrystalKernel and Crystal TWRP installer

properties() { '
kernel.string=CrystalKernel 3.18.71 for Moto Z2 Play
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=albus
supported.versions=8.1.0
supported.patchlevels=
supported.vendorpatchlevels=
'; }

boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
}

BLOCK=boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=0;

. tools/ak3-core.sh;

# ============================================================
# CrystalKernel Android neofetch-style visual block
# TWRP safe / POSIX sh / ASCII only / English only
# ============================================================

CK_TARGET="albus"
CK_AUTHOR="@Hearesaas"
CK_KERNEL_NAME="CrystalKernel"
CK_STEP_NUM=0
CK_STEP_TOTAL=6

ck_print() {
  if command -v ui_print >/dev/null 2>&1; then
    ui_print "$1"
  else
    printf '%s\n' "$1"
  fi
}

ck_line() {
  ck_print "============================================================"
}

ck_small_line() {
  ck_print "------------------------------------------------------------"
}

ck_clip() {
  printf '%.24s' "$1"
}

ck_prop_raw() {
  _p="$1"
  _v=""

  if command -v getprop >/dev/null 2>&1; then
    _v="$(getprop "$_p" 2>/dev/null)"
  elif [ -x /system/bin/getprop ]; then
    _v="$(/system/bin/getprop "$_p" 2>/dev/null)"
  elif [ -x /sbin/getprop ]; then
    _v="$(/sbin/getprop "$_p" 2>/dev/null)"
  fi

  printf '%s' "$_v"
}

ck_prop() {
  _v="$(ck_prop_raw "$1")"
  [ -n "$_v" ] || _v="unknown"
  printf '%s' "$_v"
}

ck_prop_fallback() {
  _v="$(ck_prop_raw "$1")"
  if [ -z "$_v" ]; then
    _v="$(ck_prop_raw "$2")"
  fi
  [ -n "$_v" ] || _v="unknown"
  printf '%s' "$_v"
}

ck_rom() {
  _v="$(ck_prop_raw ro.lineage.version)"
  [ -n "$_v" ] || _v="$(ck_prop_raw ro.cm.version)"
  [ -n "$_v" ] || _v="$(ck_prop_raw ro.modversion)"
  [ -n "$_v" ] || _v="$(ck_prop_raw ro.build.flavor)"
  [ -n "$_v" ] || _v="$(ck_prop_raw ro.build.display.id)"
  [ -n "$_v" ] || _v="unknown"
  printf '%s' "$_v"
}

ck_read_first_file() {
  for _f in "$@"; do
    if [ -r "$_f" ]; then
      _v="$(cat "$_f" 2>/dev/null)"
      if [ -n "$_v" ]; then
        printf '%s' "$_v"
        return
      fi
    fi
  done

  printf '%s' "unknown"
}

ck_battery_capacity() {
  _cap="$(ck_read_first_file \
    /sys/class/power_supply/battery/capacity \
    /sys/class/power_supply/bms/capacity)"

  if [ "$_cap" = "unknown" ]; then
    printf '%s' "unknown"
  else
    printf '%s%%' "$_cap"
  fi
}

ck_battery_status() {
  ck_read_first_file \
    /sys/class/power_supply/battery/status \
    /sys/class/power_supply/bms/status
}

ck_selinux() {
  if command -v getenforce >/dev/null 2>&1; then
    _se="$(getenforce 2>/dev/null)"
    [ -n "$_se" ] && printf '%s' "$_se" && return
  fi

  if [ -r /sys/fs/selinux/enforce ]; then
    _se="$(cat /sys/fs/selinux/enforce 2>/dev/null)"
    case "$_se" in
      1) printf '%s' "Enforcing" ;;
      0) printf '%s' "Permissive" ;;
      *) printf '%s' "unknown" ;;
    esac
    return
  fi

  printf '%s' "unknown"
}

ck_twrp_version() {
  _v="$(ck_prop_raw ro.twrp.version)"
  [ -n "$_v" ] || _v="$(ck_prop_raw ro.recovery.version)"
  [ -n "$_v" ] || _v="unknown"
  printf '%s' "$_v"
}

ck_slot() {
  _v="$(ck_prop_raw ro.boot.slot_suffix)"
  [ -n "$_v" ] || _v="$(ck_prop_raw ro.boot.slot)"
  [ -n "$_v" ] || _v="unknown"
  printf '%s' "$_v"
}

ck_fetch_line() {
  _left="$1"
  _right="$2"

  if [ -n "$_right" ]; then
    ck_print "$(printf '%-34s %s' "$_left" "$(ck_clip "$_right")")"
  else
    ck_print "$_left"
  fi
}

ck_neofetch_header() {
  _device="$(ck_prop_fallback ro.product.device ro.build.product)"
  _model="$(ck_prop ro.product.model)"
  _rom="$(ck_rom)"
  _android="$(ck_prop ro.build.version.release)"
  _sdk="$(ck_prop ro.build.version.sdk)"
  _build="$(ck_prop ro.build.display.id)"
  _kernel="$(uname -r 2>/dev/null || printf unknown)"
  _arch="$(uname -m 2>/dev/null || printf unknown)"
  _battery="$(ck_battery_capacity)"
  _bat_status="$(ck_battery_status)"
  _selinux="$(ck_selinux)"
  _slot="$(ck_slot)"
  _recovery="$(ck_twrp_version)"

  ck_line
  ck_print ""

  _ck_i=0
  while IFS= read -r _ck_android; do
    _ck_i=$((_ck_i + 1))

    case "$_ck_i" in
      1)  _ck_right="$CK_KERNEL_NAME@$CK_TARGET" ;;
      2)  _ck_right="-------------------" ;;
      3)  _ck_right="Author: $CK_AUTHOR" ;;
      4)  _ck_right="Kernel: $CK_KERNEL_NAME" ;;
      5)  _ck_right="Target: $CK_TARGET" ;;
      6)  _ck_right="Device: $_device" ;;
      7)  _ck_right="Model: $_model" ;;
      8)  _ck_right="ROM: $_rom" ;;
      9)  _ck_right="Android: $_android SDK $_sdk" ;;
      10) _ck_right="Linux: $_kernel" ;;
      11) _ck_right="Arch: $_arch" ;;
      12) _ck_right="Battery: $_battery $_bat_status" ;;
      13) _ck_right="SELinux: $_selinux" ;;
      14) _ck_right="Recovery: $_recovery" ;;
      15) _ck_right="Slot: $_slot" ;;
      16) _ck_right="Build: $_build" ;;
      17) _ck_right="Status: ready" ;;
      *)  _ck_right="" ;;
    esac

    ck_fetch_line "$_ck_android" "$_ck_right"
  done <<'CK_ANDROID'
         -o          o-
          +hydNNNNdyh+
        +mMMMMMMMMMMMMm+
      `dMMm:NMMMMMMN:mMMd`
      hMMMMMMMMMMMMMMMMMMh
  ..  yyyyyyyyyyyyyyyyyyyy  ..
.mMMm`MMMMMMMMMMMMMMMMMMMM`mMMm.
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
-MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM-
 +yy+ MMMMMMMMMMMMMMMMMMMM +yy+
      mMMMMMMMMMMMMMMMMMMm
      `/++MMMMh++hMMMM++/`
          MMMMo  oMMMM
          MMMMo  oMMMM
          oNMm-  -mMNs
CK_ANDROID

  ck_print ""
  ck_line
}

ck_step() {
  CK_STEP_NUM=$((CK_STEP_NUM + 1))
  ck_print "$(printf '[%02d/%02d] %s' "$CK_STEP_NUM" "$CK_STEP_TOTAL" "$1")"
}

ck_install_steps_visual() {
  ck_step "Preparing TWRP"
  ck_step "Installing TWRP"
  ck_step "Preparing CrystalKernel"
  ck_step "Installing CrystalKernel"
  ck_step "Cleaning temporary files"
  ck_step "Finalizing installation"
  ck_line
}

ck_finish_line() {
  _label="$1"
  _value="$2"
  ck_print "$(printf '%-10s %s' "$_label:" "$(ck_clip "$_value")")"
}

ck_finish_visual() {
  ck_line
  ck_print "CrystalKernel finished"
  ck_small_line
  ck_finish_line "Author" "$CK_AUTHOR"
  ck_finish_line "Target" "$CK_TARGET"
  ck_finish_line "Device" "$(ck_prop_fallback ro.product.device ro.build.product)"
  ck_finish_line "Model" "$(ck_prop ro.product.model)"
  ck_finish_line "ROM" "$(ck_rom)"
  ck_finish_line "Android" "$(ck_prop ro.build.version.release) SDK $(ck_prop ro.build.version.sdk)"
  ck_finish_line "Kernel" "$(uname -r 2>/dev/null || printf unknown)"
  ck_finish_line "Battery" "$(ck_battery_capacity) $(ck_battery_status)"
  ck_finish_line "SELinux" "$(ck_selinux)"
  ck_finish_line "Status" "completed"
  ck_line
}

TWRP_SHA256=a01ce7361195c1b100ebf994ab65ccd4d54ba10fb7194245d3b77ead8dccdd93;
TWRP_SIZE=20721664;
RECOVERY_LIMIT=21073920;

ck_neofetch_header

[ -f "$AKHOME/Image.gz" ] || abort "Image.gz is missing. Installation aborted.";
[ -f "$AKHOME/recovery.img" ] || abort "Crystal TWRP image is missing. Installation aborted.";

[ "$(dd if="$AKHOME/recovery.img" bs=8 count=1 2>/dev/null)" = "ANDROID!" ] || \
  abort "Crystal TWRP header is invalid. Installation aborted.";

twrp_size=$(wc -c < "$AKHOME/recovery.img");
[ "$twrp_size" = "$TWRP_SIZE" ] || abort "Crystal TWRP size is unexpected. Installation aborted.";
[ "$twrp_size" -le "$RECOVERY_LIMIT" ] || abort "Crystal TWRP exceeds the recovery partition. Installation aborted.";

twrp_hash=$(sha256sum "$AKHOME/recovery.img" | awk '{print $1}');
[ "$twrp_hash" = "$TWRP_SHA256" ] || abort "Crystal TWRP SHA-256 verification failed. Installation aborted.";

recovery_block=/dev/block/bootdevice/by-name/recovery;
[ -e "$recovery_block" ] || recovery_block=/dev/block/by-name/recovery;
[ -e "$recovery_block" ] || abort "Recovery partition was not found. Installation aborted.";

recovery_capacity=$(blockdev --getsize64 "$recovery_block" 2>/dev/null);
[ "$recovery_capacity" ] || abort "Recovery partition size could not be read. Installation aborted.";
[ "$twrp_size" -le "$recovery_capacity" ] || abort "Crystal TWRP does not fit in the recovery partition. Installation aborted.";

ck_install_steps_visual

dump_boot;

# Android 8 exposes the working TUN device as /dev/tun, while DroidSpaces
# checks the conventional Linux path /dev/net/tun.
append_file init.rc "albus-crystal-tun" albus-crystal-tun.rc;

write_boot;
flash_generic recovery;

ck_finish_visual
