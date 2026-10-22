#!/usr/bin/env python3
"""Print the Music/Off amp settings used by sapphire's vendor firmware.

The formats follow the Xiaomi Qualcomm fs1815 fsm_core.c/fsm-dev.h and
aw87xxx_acf_bin.c/aw87xxx_bin_parse.c sources. This runs on the host only.
"""

import argparse
import hashlib
import struct
from pathlib import Path

AW_SHA256 = "402562f7f05ceb3e3eeb4e4160d42104116aa273000837650e149337f4b2160d"
FS_SHA256 = "1d520d06ab543548d8797f72801793c5a4162a88c39f32ee28c11735acdc59bc"


def u16(data, offset):
    return struct.unpack_from("<H", data, offset)[0]


def u32(data, offset):
    return struct.unpack_from("<I", data, offset)[0]


def load(path, expected):
    data = Path(path).read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if digest != expected:
        raise ValueError(f"{path}: SHA256 {digest}, expected {expected}")
    return data


def aw_profiles(data):
    if u32(data, 0) != 0x0A15F908 or u32(data, 64) != 1:
        raise ValueError("unknown ACF header")
    table_size, count, table = u32(data, 52), u32(data, 56), u32(data, 60)
    entry_size = table_size // count if count else 0
    if entry_size != 64 or table_size != count * entry_size or table + table_size > len(data):
        raise ValueError("invalid ACF directory")
    result = {}
    for index in range(count):
        at = table + index * entry_size
        kind, name, device, bus, address, profile, data_type, size, start = struct.unpack_from(
            "<I16sHHHHIII", data, at
        )
        if kind != 2 or name.rstrip(b"\0") != b"aw87559" or data_type != 4:
            continue
        if device not in (0, 1) or profile not in (0, 11):
            continue
        if start + size > len(data) or size < 64:
            raise ValueError("invalid ACF profile bounds")
        if u32(data, start + 8) != 0 or u32(data, start + 32) != 1 or u32(data, start + 36) != 1:
            raise ValueError("unexpected ACF register encoding")
        nregs = u32(data, start + 60)
        if size != 64 + nregs * 2:
            raise ValueError("ACF register count mismatch")
        pairs = [tuple(data[start + 64 + pos : start + 66 + pos]) for pos in range(0, nregs * 2, 2)]
        result[(device, profile)] = pairs
    if set(result) != {(0, 0), (0, 11), (1, 0), (1, 11)}:
        raise ValueError(f"missing Music/Off profiles: {result.keys()}")
    return result


def fs_profiles(data):
    if u16(data, 0) != 0x0100 or u16(data, 22) != len(data) or u16(data, 26) != 2:
        raise ValueError("unknown FSM header")
    result = {}
    for index in range(2):
        start, kind = struct.unpack_from("<HH", data, 28 + index * 4)
        if kind != 0 or start + 40 > len(data):
            raise ValueError("invalid FSM device directory")
        address, chip, sections = u16(data, start + 30), u16(data, start + 32), u16(data, start + 26)
        if address not in (0x34, 0x35) or chip != 0x1220:
            raise ValueError("unexpected FSM chip/address")
        directory = start + 40
        entries = {}
        for section in range(sections):
            offset, section_type = struct.unpack_from("<HH", data, directory + section * 4)
            entries[section_type] = directory + offset
        common_at, scene_at, info_at = entries[2], entries[3], entries[1]
        common = [struct.unpack_from("<HH", data, common_at + 2 + i * 4)
                  for i in range(u16(data, common_at))]
        music = [(bf, value) for i in range(u16(data, scene_at))
                 for scene, bf, value in [struct.unpack_from("<HHH", data, scene_at + 2 + i * 6)]
                 if scene & 1]
        tcoef = u16(data, info_at + 2 + 2)  # FSM_INFO_SPK_TEMPR_COEF
        result[address] = (tcoef, common, music)
    if set(result) != {0x34, 0x35}:
        raise ValueError("missing FS1815 stereo pair")
    return result


def show_reg(reg, value):
    return f"{{ 0x{reg:02x}, 0x{value:04x} }}"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--aw", type=Path, required=True)
    parser.add_argument("--fs", type=Path, required=True)
    args = parser.parse_args()
    aw = aw_profiles(load(args.aw, AW_SHA256))
    fs = fs_profiles(load(args.fs, FS_SHA256))
    for address, device in ((0x58, 1), (0x5B, 0)):
        for profile, name in ((0, "Music"), (11, "Off")):
            pairs = aw[(device, profile)]
            print(f"AW87559 {name} 0x{address:02x}, dev_index {device}, {len(pairs)} entries")
            print(", ".join(show_reg(*pair) for pair in pairs))
    for address, (tcoef, common, music) in fs.items():
        print(f"FS1815 0x{address:02x}, tcoef 0x{tcoef:04x}, {len(common)} common, {len(music)} Music")
        for name, pairs in (("common", common), ("Music", music)):
            print(name + ": " + ", ".join(show_reg(*pair) for pair in pairs))


if __name__ == "__main__":
    main()
