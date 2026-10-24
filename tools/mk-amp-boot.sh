#!/usr/bin/env bash
# Wrap a TOPAZ_4K SWEET kernel in the eight-core sapphire boot image.
set -euo pipefail

if [ "$#" -ne 2 ]; then
	echo "usage: $0 KERNEL OUT.img" >&2
	exit 2
fi

repo=$(cd "$(dirname "$0")/.." && pwd)
kernel=$(realpath "$1")
output=$(realpath -m "$2")
test -s "$kernel" || { echo "missing kernel: $kernel" >&2; exit 1; }

# The TOPAZ_4K patch links __TEXT at the compact 4K kernel VA. Refuse a
# normal 16K artifact, since its Silver CPU_ON would fail after the handoff.
python3 - "$repo" "$kernel" <<'PY'
import sys
sys.path.insert(0, sys.argv[1] + '/tools')
from mkpayload import parse_macho

with open(sys.argv[2], 'rb') as f:
    macho = parse_macho(f.read())
if macho['segs'][0]['vmaddr'] != 0xfffffff007004000:
    raise SystemExit('kernel is not linked for TOPAZ_4K (expected __TEXT at 0xfffffff007004000)')
PY

mkdir -p "$repo/shim/out"
tmp=$(mktemp -d "$repo/shim/out/amp.XXXXXXXX")
trap 'rm -rf "$tmp"' EXIT
if [ -z "${D22AP_ADT:-}" ]; then
	D22AP_ADT="$repo/research/ipsw-x/d22ap.adt"
	if [ ! -s "$D22AP_ADT" ]; then
		D22AP_ADT=/home/fryad/projects/ios-sapphire/research/ipsw-x/d22ap.adt
	fi
fi
export D22AP_ADT
test -s "$D22AP_ADT" || { echo "set D22AP_ADT to the extracted d22ap.adt" >&2; exit 1; }
adt_args=()
if [ -n "${AUDIO_SCRIPT:-}" ]; then
	adt_args+=(--audio-script "$AUDIO_SCRIPT")
fi
python3 "$repo/tools/mkadt.py" "$tmp/sapphire-amp.adt" --highmem --amp "${adt_args[@]}"

cmdline="debug=0xc serial=3 cpus=8 keepsyms=1 -noprogress rd=ufsroot0 unentitled_ios_sim_launch=1 ignition_level=1 wdt_test=no_user_checkin ufsrw=1 rootrw=1 launchd_unsecure_cache=1 wdt=-1 sweetfb_noconsole=1 sweetfb_hz=${SWEETFB_HZ:-30} sweettouchxmax=2160 sweettouchymax=2400 modem=1 wifi=1 gpu=1 topaz_inject=/topaz/lib/libtopaz-inject.dylib,backboardd,containermanagerd,containermanagerd_system adsp=1 gpu_mhz=${GPU_MHZ:-600} sapphire_amp=1${EXTRA_ARGS:+ $EXTRA_ARGS}"
echo "boot-args: ${#cmdline} chars" >&2
if [ ${#cmdline} -ge 600 ]; then echo 'boot-args must be under 600 chars' >&2; exit 1; fi
python3 "$repo/tools/mkpayload.py" "$kernel" "$tmp/sapphire-amp.adt" "$tmp/payload.bin" --cmdline "$cmdline"

export MKBOOTIMG="${MKBOOTIMG:-python3 /home/fryad/projects/lunaris/src/system/tools/mkbootimg/mkbootimg.py}"
(cd "$repo/shim" && SHIM_AMP=1 ./build.sh "$tmp/payload.bin")
mkdir -p "$(dirname "$output")"
cp "$repo/shim/out/shim-boot.img" "$output"
sha256sum "$output"
