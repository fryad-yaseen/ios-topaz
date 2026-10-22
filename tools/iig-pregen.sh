#!/bin/sh
# Stand-in for Xcode's iig: copies the header and implementation that Xcode 15.4's iig
# generated (xnu/iig-pregen, from a GitHub macos-14 build). Newer iig (Xcode 16+) emits
# IORPC.kernelContent, which xnu-8796 lacks; the rest of the kernel builds with newer Xcode.
# The DriverKit .iig sources are not touched by our patches; if one is, regenerate with Xcode 15.
# Use: IIG=/path/to/tools/iig-pregen.sh in the environment of build.sh.
set -eu
dir=$(cd "$(dirname "$0")/../xnu/iig-pregen" && pwd)
header= impl=
while [ $# -gt 0 ]; do
	case $1 in
	--header) header=$2; shift ;;
	--impl) impl=$2; shift ;;
	--) break ;;
	esac
	shift
done
[ -n "$header" ] && [ -n "$impl" ] || { echo "iig-pregen: need --header and --impl" >&2; exit 1; }
for f in "$header" "$impl"; do
	src=$dir/$(basename "$f")
	[ -f "$src" ] || { echo "iig-pregen: no pregenerated $(basename "$f")" >&2; exit 1; }
	cp "$src" "$f"
done
echo "iig-pregen: $(basename "$header") $(basename "$impl")"
