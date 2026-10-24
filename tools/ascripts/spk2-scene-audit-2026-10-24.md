# FS1815 scene table audit, 2026-10-24

Local firmware SHA256 `1d520d06ab543548d8797f72801793c5a4162a88c39f32ee28c11735acdc59bc`. Binary kept outside git.

Decoded with packed fsm-dev.h: header28 bytes, index entries4 bytes, dev index at device+40; section offsets relative to index. Type2 common has uint16 count then4-byte units; type3 scene has uint16 count then6-byte scene/unit/value entries. Bounds checked.

## Amp 34

- Type2, scene `0000`: `f03e=8500`, `f03f=8110`, `f04c=7008`, `f02a=0030`, `f058=827a`, `f059=d821`, `f05a=d841`, `f05b=007b`, `f05c=0000`, `f088=a000`, `f089=0032`, `44bc=0002`, `034c=0000`, `f0b8=0002`, `f05d=2005`
- Type3, scene `0001`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000b`, `f05a=fcab`, `f01f=0000`
- Type3, scene `0002`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0001`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=0007`, `f05a=fcba`, `f01f=0000`
- Type3, scene `0004`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=0007`, `f05a=fcba`, `f01f=0000`
- Type3, scene `0020`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=0007`, `f05a=fcba`, `f01f=0000`
- Type3, scene `0040`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=0007`, `f05a=0841`, `f01f=0000`
- Type3, scene `0080`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=0007`, `f05a=fcba`, `f01f=0000`
- Type3, scene `0100`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=0007`, `f05a=0841`, `f01f=0000`
- Type3, scene `8000`: `f020=0000`, `f022=0208`, `f023=0027`, `f018=0000`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=0007`, `f05a=0841`, `f01f=0000`

## Amp 35

- Type2, scene `0000`: `f03e=8500`, `f03f=8110`, `f04c=7008`, `f02a=0030`, `f058=827a`, `f059=d821`, `f05a=d841`, `f05b=007b`, `f05c=0000`, `f088=a000`, `f089=0032`, `44bc=0002`, `034c=0000`, `f0b8=0002`, `f05d=2005`
- Type3, scene `0001`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000e`, `f05a=fcab`, `f01f=0000`
- Type3, scene `0002`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0001`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000b`, `f05a=fcba`, `f01f=0000`
- Type3, scene `0004`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000b`, `f05a=fcba`, `f01f=0000`
- Type3, scene `0020`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000b`, `f05a=fcba`, `f01f=0000`
- Type3, scene `0040`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000b`, `f05a=0841`, `f01f=0000`
- Type3, scene `2000`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000b`, `f05a=fcba`, `f01f=0000`
- Type3, scene `4000`: `f020=1722`, `f022=0208`, `f023=0027`, `f018=000a`, `0f3f=0000`, `0fbc=0000`, `f01f=ca91`, `f058=827a`, `3c59=0000`, `4019=000b`, `f05a=0841`, `f01f=0000`

No common/scene unit targets AF or C4. No special delay/poll opcode appears in these tables. Scene masks differ by amp; a WCD mode number cannot safely be used as a firmware bit index. In particular Receiver=10 in the neighboring AW profile enum is not evidence for a FS scene1<<10.
