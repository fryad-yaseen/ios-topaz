#!/usr/bin/env bash
# Build and package the iOS GPU libraries. Run from the repository root.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo"
out="$repo/out-userland"
lib="$out/topaz/lib"
mesa="$repo/userland/build-mesa"
sdk=$(xcrun --sdk iphoneos --show-sdk-path)
cc=$(xcrun --sdk iphoneos --find clang)

test -d "$sdk"
test -x "$cc"
mkdir -p "$lib" "$mesa"
echo "iPhoneOS SDK: $sdk"
xcodebuild -version
"$cc" --version | head -n 1
brew --version | head -n 1
brew install meson ninja bison
meson --version
ninja --version
"$(brew --prefix bison)/bin/bison" --version | head -n 1
python3 --version

# The upstream script looks for mesa/ beside itself and writes to build-mesa/.
# Copy it there without changing its Mesa setup, patching, or build logic.
cp userland/mesa/mk-mesa-mac.sh userland/mk-mesa-mac.sh
DRIVERS=softpipe,freedreno bash userland/mk-mesa-mac.sh
test -s "$mesa/out/libOSMesa.8.dylib"
test -s "$mesa/out/gl.xml"
test -s "$mesa/out/exported-gl.txt"
cp "$mesa/out/libOSMesa.8.dylib" "$lib/libOSMesa.8.dylib"

# Mesa may link OSMesa against a separate shared glapi. Install that exact
# library and change OSMesa's load command to the phone's absolute path.
# (grep, not awk: macOS awk rejects "[^/]" inside /.../)
glapi_ref=$(otool -L "$lib/libOSMesa.8.dylib" | tail -n +2 | awk '{ print $1 }' | grep -E '(^|/)libglapi[^/]*\.dylib$' || true)
if [[ -n "$glapi_ref" ]]; then
  [[ "$glapi_ref" != *$'\n'* ]] || { echo "Multiple libglapi dependencies" >&2; exit 1; }
  glapi_name=${glapi_ref##*/}
  glapi_source=
  while IFS= read -r candidate; do
    glapi_source=$candidate
    break
  done < <(find "$mesa/build-softpipe-freedreno" -name "$glapi_name" -print)
  test -n "$glapi_source"
  cp -L "$glapi_source" "$lib/$glapi_name"
  test -s "$lib/$glapi_name"
  install_name_tool -id "/topaz/lib/$glapi_name" "$lib/$glapi_name"
  install_name_tool -change "$glapi_ref" "/topaz/lib/$glapi_name" "$lib/libOSMesa.8.dylib"
fi
install_name_tool -id /topaz/lib/libOSMesa.8.dylib "$lib/libOSMesa.8.dylib"

python3 userland/gpu/gen/mkeagl.py \
  userland/gpu/gen/eagl_slots.txt "$mesa/out/gl.xml" \
  "$mesa/out/exported-gl.txt" userland/gpu/eagl.c > "$mesa/eagl_gen.h"
test -s "$mesa/eagl_gen.h"

# The iPhoneOS SDK can omit public IOKit headers. The macOS SDK supplies
# compatible declarations; only the iPhoneOS SDK supplies linked frameworks.
macos_sdk=$(xcrun --sdk macosx --show-sdk-path)
if [[ ! -f "$sdk/System/Library/Frameworks/IOKit.framework/Headers/IOKitLib.h" ]]; then
  test -f "$macos_sdk/System/Library/Frameworks/IOKit.framework/Headers/IOKitLib.h"
  mkdir -p "$mesa/ios-headers"
  ln -sfn "$macos_sdk/System/Library/Frameworks/IOKit.framework/Headers" "$mesa/ios-headers/IOKit"
  iokit_include=(-I"$mesa/ios-headers")
else
  iokit_include=()
fi

target=(-target arm64-apple-ios16.0 -isysroot "$sdk")
"$cc" "${target[@]}" "${iokit_include[@]}" -I"$mesa" \
  -dynamiclib -Wl,-undefined,error -install_name /topaz/lib/libtopaz-gl.dylib \
  -framework CoreFoundation -framework IOKit -framework IOSurface -lobjc \
  "$lib/libOSMesa.8.dylib" \
  userland/gpu/eagl.c userland/gpu/gl_osmesa.c -o "$lib/libtopaz-gl.dylib"
"$cc" "${target[@]}" "${iokit_include[@]}" \
  -dynamiclib -Wl,-undefined,error -install_name /topaz/lib/libtopaz-inject.dylib \
  -framework CoreFoundation -framework IOKit -lobjc \
  userland/gpu/topaz_inject.c -o "$lib/libtopaz-inject.dylib"

test -s "$lib/libOSMesa.8.dylib"
test -s "$lib/libtopaz-gl.dylib"
test -s "$lib/libtopaz-inject.dylib"

: > "$out/otool-L.txt"
for dylib in "$lib"/*.dylib; do
  test -s "$dylib"
  name=${dylib##*/}
  test "$(otool -D "$dylib" | tail -n 1)" = "/topaz/lib/$name"
  test "$(lipo -archs "$dylib")" = arm64
  codesign -f -s - "$dylib"
  codesign --verify "$dylib"
  otool -L "$dylib" >> "$out/otool-L.txt"
  otool -L "$dylib" | awk 'NR > 1 { print $1 }' | while IFS= read -r dep; do
    case "$dep" in
      /topaz/lib/*|/usr/lib/*|/System/Library/Frameworks/*|/System/Library/PrivateFrameworks/*) ;;
      *) echo "Unexpected dependency in $name: $dep" >&2; exit 1 ;;
    esac
  done
done

(cd "$out" && shasum -a 256 topaz/lib/*.dylib > SHA256SUMS)
test -s "$out/SHA256SUMS"
cat "$out/otool-L.txt"
cat "$out/SHA256SUMS"
