#!/usr/bin/env bash
# One script per boot. Run only with the phone attached in fastboot.
set -euo pipefail
if [ "$#" -lt 1 ]; then echo "usage: $0 SCRIPT [EXTRA_ARGS...]" >&2; exit 2; fi
repo=$(cd "$(dirname "$0")/.." && pwd)
script=$(realpath "$1")
shift
test -s "$script" || { echo "missing script: $script" >&2; exit 1; }
kernel=${AUDIO_KERNEL:-/home/fryad/ios-build/xnu-cm-24/out-4k/kernel.development.sweet}
out=${AUDIO_BOOT_IMAGE:-/tmp/sapphire-audio-run.img}
log=${AUDIO_LOG:-/tmp/sapphire-audio-$(date +%Y%m%d-%H%M%S).txt}
# mk-amp-boot already supplies sapphire_amp=1.
base='gpu_vote=1 sapphire_spk=1 sapphire_spk_fix=1 sapphire_spk_xm=1 sapphire_spk_ref=1 sapphire_swr_ref=1 sapphire_ascript=1 sapphire_autoreboot=45'
export AUDIO_SCRIPT="$script" GPU_MHZ=785 EXTRA_ARGS="$base${*:+ $*}"
"$repo/tools/mk-amp-boot.sh" "$kernel" "$out"
echo "Waiting for fastboot..." >&2
until fastboot devices | grep -q .; do sleep 2; done
if fastboot getvar all 2>&1 | grep -q 'unbootable:a:yes'; then fastboot set_active a; fi
fastboot boot "$out"
echo "Waiting for OrangeFox recovery..." >&2
timeout 180 bash -c 'until adb devices 2>/dev/null | grep -q recovery; do sleep 3; done'
sleep 5
for attempt in 1 2 3; do
  if "$repo/tools/sweet-log-pull.sh" "$log"; then break; fi
  if [ "$attempt" -eq 3 ]; then echo 'log pull failed' >&2; exit 1; fi
  sleep 8
done
echo "Log: $log"
grep -E 'TopazAudio: (as|spktest)|FS1815' "$log" > "$log.summary" || true
cat "$log.summary"
adb reboot bootloader
